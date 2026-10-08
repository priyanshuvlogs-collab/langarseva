-- LangarSeva hardening (QA pass, 2026-10-08)
--
-- Applied to project pbjfpahqtvearfvcuogj on 2026-10-08 via execute_sql in parts
-- (apply_migration times out). Verified with 19 rolled-back scenario checks.
--
-- 1. Overnight timings: a row on day D with opens_at > closes_at (e.g. 20:00-02:00)
--    now covers D 20:00-24:00 and D+1 00:00-02:00. Before, it covered the early
--    hours of D itself, which is the previous night.
-- 2. Seva capacity is enforced on the server, with a row lock so two people
--    cannot take the last spot at the same time. Ended slots cannot be joined.
-- 3. nearby_langars clamps radius and limit so one call cannot scan the table.
-- 4. Length and format checks on user-submitted text, UPI IDs and donate URLs.
--    Non-admin photo URLs must point into the caller's own storage folder.
-- 5. Dashboard / service-role edits are trusted, so approving a langar from the
--    Supabase table editor sticks instead of resetting to pending.
-- 6. submit_langar() inserts a langar and its timings in one transaction, so a
--    failed timings insert no longer leaves a half-saved langar behind.

-- ---------- 1. overnight timings ----------
create or replace function public.langar_is_open(p_langar_id uuid, p_at timestamptz default now())
returns boolean language sql stable set search_path = public, extensions as $$
  with ist as (
    select (p_at at time zone 'Asia/Kolkata')::time as t,
           extract(dow from (p_at at time zone 'Asia/Kolkata'))::int as dow
  )
  select exists (
    select 1
    from public.langar_timings lt, ist
    where lt.langar_id = p_langar_id
      and (
        (lt.day_of_week = ist.dow and (
            lt.is_24h
            or (lt.opens_at <= lt.closes_at and ist.t between lt.opens_at and lt.closes_at)
            or (lt.opens_at >  lt.closes_at and ist.t >= lt.opens_at)))
        -- tail of last night's overnight session
        or (lt.day_of_week = (ist.dow + 6) % 7 and not lt.is_24h
            and lt.opens_at > lt.closes_at and ist.t <= lt.closes_at)
      )
  );
$$;

-- ---------- 2. seva capacity ----------
create or replace function public.seva_signup_guard()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_capacity int;
  v_ends timestamptz;
  v_taken int;
begin
  if tg_op = 'UPDATE' and (new.slot_id <> old.slot_id or new.user_id <> old.user_id) then
    raise exception 'signup_immutable' using errcode = 'P0001';
  end if;
  if new.status = 'joined' and (tg_op = 'INSERT' or old.status <> 'joined') then
    -- Lock the slot row so concurrent joins for the same slot queue up here.
    select capacity, ends_at into v_capacity, v_ends from public.seva_slots where id = new.slot_id for update;
    if not found then
      raise exception 'slot_not_found' using errcode = 'P0001';
    end if;
    if v_ends < now() then
      raise exception 'slot_ended' using errcode = 'P0001';
    end if;
    select count(*) into v_taken from public.seva_signups
      where slot_id = new.slot_id and status = 'joined' and user_id <> new.user_id;
    if v_taken >= v_capacity then
      raise exception 'slot_full' using errcode = 'P0001';
    end if;
  end if;
  return new;
end;
$$;
drop trigger if exists seva_signup_guard_trg on public.seva_signups; -- no-op on a fresh project
create trigger seva_signup_guard_trg before insert or update on public.seva_signups
  for each row execute function public.seva_signup_guard();
revoke execute on function public.seva_signup_guard() from public, anon, authenticated;

-- ---------- 3. bounded nearby search ----------
create or replace function public.nearby_langars(
  p_lat double precision,
  p_lng double precision,
  p_radius_m double precision default 25000,
  p_open_now boolean default false,
  p_limit int default 100
)
returns table (
  id uuid, name text, description text, lat double precision, lng double precision,
  address text, city text, state text, photos text[], contact_phone text,
  donate_upi_id text, donate_url text, distance_m double precision, is_open boolean
)
language sql stable set search_path = public, extensions as $$
  with q as (
    select st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography as pt,
           least(greatest(coalesce(p_radius_m, 25000), 100), 200000) as r,
           least(greatest(coalesce(p_limit, 100), 1), 200) as n
  )
  select l.id, l.name, l.description, l.lat, l.lng, l.address, l.city, l.state, l.photos,
         l.contact_phone, l.donate_upi_id, l.donate_url,
         st_distance(l.location, q.pt) as distance_m,
         public.langar_is_open(l.id) as is_open
  from public.langars l, q
  where l.status = 'approved'
    and p_lat between -90 and 90 and p_lng between -180 and 180
    and st_dwithin(l.location, q.pt, q.r)
    and (not coalesce(p_open_now, false) or public.langar_is_open(l.id))
  order by distance_m
  limit (select n from q);
$$;

-- ---------- 4. data validation ----------
alter table public.langars
  add constraint langars_description_len check (description is null or char_length(description) <= 2000),
  add constraint langars_address_len check (address is null or char_length(address) <= 300),
  add constraint langars_city_len check (city is null or char_length(city) <= 100),
  add constraint langars_state_len check (state is null or char_length(state) <= 100),
  add constraint langars_rejection_len check (rejection_reason is null or char_length(rejection_reason) <= 500),
  add constraint langars_phone_fmt check (contact_phone is null or contact_phone ~ '^\+?[0-9][0-9 ()-]{5,19}$'),
  add constraint langars_upi_fmt check (donate_upi_id is null or donate_upi_id ~ '^[A-Za-z0-9._-]{2,255}@[A-Za-z0-9]{2,64}$'),
  add constraint langars_url_fmt check (donate_url is null or (donate_url ~* '^https://[^\s/$.?#][^\s]*$' and char_length(donate_url) <= 500)),
  add constraint langars_photos_max check (cardinality(photos) <= 5);

alter table public.seva_slots
  add constraint seva_slots_title_len check (char_length(title) between 2 and 120),
  add constraint seva_slots_desc_len check (description is null or char_length(description) <= 1000),
  add constraint seva_slots_capacity_max check (capacity <= 1000);

alter table public.reports
  add constraint reports_reason_len check (char_length(btrim(reason)) between 1 and 1000);

-- Non-admin photo URLs must be public URLs inside the caller's own folder.
create or replace function public.langars_guard()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  new.updated_at := now();
  -- Trusted server roles (dashboard table editor, SQL editor, service role) have
  -- no auth.uid(); they act as admins. Without this, approving a langar from the
  -- dashboard silently reset it to pending.
  if auth.uid() is null and current_user not in ('anon', 'authenticated') then
    return new;
  end if;
  if not public.is_admin() then
    if exists (
      select 1 from unnest(new.photos) p
      where p not like '%/storage/v1/object/public/langar-photos/' || auth.uid()::text || '/%'
    ) and (tg_op = 'INSERT' or new.photos is distinct from old.photos) then
      raise exception 'invalid_photo_url' using errcode = 'P0001';
    end if;
    new.status := 'pending';
    new.rejection_reason := null;
    if tg_op = 'INSERT' then
      new.submitted_by := auth.uid();
    else
      -- owners may edit content, but editing re-queues for review
      new.submitted_by := old.submitted_by;
    end if;
  end if;
  return new;
end;
$$;
revoke execute on function public.langars_guard() from public, anon, authenticated;

-- ---------- 6. atomic submit ----------
create or replace function public.submit_langar(p jsonb, p_timings jsonb default '[]'::jsonb)
returns uuid language plpgsql security invoker set search_path = public as $$
declare
  v_id uuid;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = '42501';
  end if;
  if jsonb_typeof(coalesce(p_timings, '[]'::jsonb)) <> 'array' or jsonb_array_length(coalesce(p_timings, '[]'::jsonb)) > 28 then
    raise exception 'invalid_timings' using errcode = 'P0001';
  end if;
  insert into public.langars (name, description, lat, lng, address, city, state, contact_phone, donate_upi_id, donate_url, photos)
  values (
    btrim(p->>'name'),
    nullif(btrim(p->>'description'), ''),
    (p->>'lat')::double precision,
    (p->>'lng')::double precision,
    nullif(btrim(p->>'address'), ''),
    nullif(btrim(p->>'city'), ''),
    nullif(btrim(p->>'state'), ''),
    nullif(btrim(p->>'contact_phone'), ''),
    nullif(btrim(p->>'donate_upi_id'), ''),
    nullif(btrim(p->>'donate_url'), ''),
    coalesce(array(select jsonb_array_elements_text(coalesce(p->'photos', '[]'::jsonb))), '{}')
  )
  returning id into v_id;

  insert into public.langar_timings (langar_id, day_of_week, opens_at, closes_at, is_24h)
  select v_id,
         (t->>'day_of_week')::smallint,
         (t->>'opens_at')::time,
         (t->>'closes_at')::time,
         coalesce((t->>'is_24h')::boolean, false)
  from jsonb_array_elements(coalesce(p_timings, '[]'::jsonb)) t;

  return v_id;
end;
$$;
revoke execute on function public.submit_langar(jsonb, jsonb) from public, anon;
grant execute on function public.submit_langar(jsonb, jsonb) to authenticated;
