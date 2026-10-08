-- LangarSeva initial schema
--
-- Applied to project pbjfpahqtvearfvcuogj (ap-south-1) on 2026-10-08 in chunks
-- (0001_types_profiles, 0002_tables, 0003_rls, 0004_delete_policies,
-- 0005_lock_down_trigger_functions; RPC functions via SQL editor). This file is the
-- single source of truth for a fresh project.
create extension if not exists postgis with schema extensions;
create extension if not exists pgcrypto;

-- ---------- enums ----------
create type public.user_role as enum ('user', 'admin');
create type public.langar_status as enum ('pending', 'approved', 'rejected');
create type public.signup_status as enum ('joined', 'cancelled');

-- ---------- profiles ----------
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  phone text,
  role public.user_role not null default 'user',
  locale text not null default 'en',
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, display_name, phone)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name'),
    new.phone
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'
  );
$$;

-- ---------- langars ----------
create table public.langars (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 2 and 120),
  description text,
  lat double precision not null check (lat between -90 and 90),
  lng double precision not null check (lng between -180 and 180),
  location geography(point, 4326) generated always as (st_setsrid(st_makepoint(lng, lat), 4326)::geography) stored,
  address text,
  city text,
  state text,
  photos text[] not null default '{}',
  contact_phone text,
  donate_upi_id text,
  donate_url text,
  submitted_by uuid references public.profiles (id) on delete set null,
  status public.langar_status not null default 'pending',
  rejection_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index langars_location_idx on public.langars using gist (location);
create index langars_status_idx on public.langars (status);
create index langars_city_idx on public.langars (lower(city));

-- Non-admins always submit as pending; only admins can change status.
create or replace function public.langars_guard()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  new.updated_at := now();
  if tg_op = 'INSERT' then
    if not public.is_admin() then
      new.status := 'pending';
      new.rejection_reason := null;
      new.submitted_by := auth.uid();
    end if;
  elsif tg_op = 'UPDATE' then
    if not public.is_admin() then
      -- owners may edit content, but editing re-queues for review
      new.status := 'pending';
      new.rejection_reason := null;
      new.submitted_by := old.submitted_by;
    end if;
  end if;
  return new;
end;
$$;
create trigger langars_guard_trg before insert or update on public.langars
  for each row execute function public.langars_guard();

-- Trigger functions must not be callable through the REST RPC endpoint.
revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function public.langars_guard() from public, anon, authenticated;

-- ---------- timings ----------
create table public.langar_timings (
  id uuid primary key default gen_random_uuid(),
  langar_id uuid not null references public.langars (id) on delete cascade,
  day_of_week smallint not null check (day_of_week between 0 and 6), -- 0 = Sunday
  opens_at time,
  closes_at time,
  is_24h boolean not null default false,
  check (is_24h or (opens_at is not null and closes_at is not null))
);
create index langar_timings_langar_idx on public.langar_timings (langar_id);

-- ---------- seva ----------
create table public.seva_slots (
  id uuid primary key default gen_random_uuid(),
  langar_id uuid not null references public.langars (id) on delete cascade,
  title text not null,
  description text,
  starts_at timestamptz not null,
  ends_at timestamptz not null check (ends_at > starts_at),
  capacity int not null default 10 check (capacity > 0),
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now()
);
create index seva_slots_langar_idx on public.seva_slots (langar_id, starts_at);

create table public.seva_signups (
  slot_id uuid not null references public.seva_slots (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  status public.signup_status not null default 'joined',
  created_at timestamptz not null default now(),
  primary key (slot_id, user_id)
);

-- ---------- favourites & reports ----------
create table public.favourites (
  user_id uuid not null references public.profiles (id) on delete cascade,
  langar_id uuid not null references public.langars (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, langar_id)
);

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  langar_id uuid not null references public.langars (id) on delete cascade,
  user_id uuid references public.profiles (id) on delete set null,
  reason text not null,
  created_at timestamptz not null default now()
);

-- ---------- views / RPC ----------
-- Is a langar open right now (IST)?
create or replace function public.langar_is_open(p_langar_id uuid, p_at timestamptz default now())
returns boolean language sql stable set search_path = public, extensions as $$
  with ist as (
    select (p_at at time zone 'Asia/Kolkata') as local_ts
  )
  select exists (
    select 1
    from public.langar_timings t, ist
    where t.langar_id = p_langar_id
      and t.day_of_week = extract(dow from ist.local_ts)::int
      and (
        t.is_24h
        or (t.opens_at <= t.closes_at and ist.local_ts::time between t.opens_at and t.closes_at)
        or (t.opens_at >  t.closes_at and (ist.local_ts::time >= t.opens_at or ist.local_ts::time <= t.closes_at)) -- overnight
      )
  );
$$;

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
  select l.id, l.name, l.description, l.lat, l.lng, l.address, l.city, l.state, l.photos,
         l.contact_phone, l.donate_upi_id, l.donate_url,
         st_distance(l.location, st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography) as distance_m,
         public.langar_is_open(l.id) as is_open
  from public.langars l
  where l.status = 'approved'
    and st_dwithin(l.location, st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography, p_radius_m)
    and (not p_open_now or public.langar_is_open(l.id))
  order by distance_m
  limit p_limit;
$$;

-- Account deletion (App Store requirement) is handled by the `delete-account`
-- Edge Function (supabase/functions/delete-account), which calls the Auth admin
-- API. Related rows cascade from auth.users -> profiles.

-- ---------- RLS ----------
alter table public.profiles enable row level security;
alter table public.langars enable row level security;
alter table public.langar_timings enable row level security;
alter table public.seva_slots enable row level security;
alter table public.seva_signups enable row level security;
alter table public.favourites enable row level security;
alter table public.reports enable row level security;

-- profiles
create policy "profiles: read own or admin" on public.profiles for select
  using (id = auth.uid() or public.is_admin());
create policy "profiles: update own" on public.profiles for update
  using (id = auth.uid()) with check (id = auth.uid() and role = (select role from public.profiles where id = auth.uid()));

-- langars
create policy "langars: public read approved" on public.langars for select
  using (status = 'approved' or submitted_by = auth.uid() or public.is_admin());
create policy "langars: authenticated insert" on public.langars for insert to authenticated
  with check (true);
create policy "langars: owner or admin update" on public.langars for update to authenticated
  using (submitted_by = auth.uid() or public.is_admin());
create policy "langars: admin delete" on public.langars for delete to authenticated
  using (public.is_admin());

-- timings: readable when parent is readable; writable by owner/admin
create policy "timings: read" on public.langar_timings for select
  using (exists (select 1 from public.langars l where l.id = langar_id));
create policy "timings: owner/admin write" on public.langar_timings for all to authenticated
  using (exists (select 1 from public.langars l where l.id = langar_id and (l.submitted_by = auth.uid() or public.is_admin())))
  with check (exists (select 1 from public.langars l where l.id = langar_id and (l.submitted_by = auth.uid() or public.is_admin())));

-- seva slots
create policy "slots: public read" on public.seva_slots for select
  using (exists (select 1 from public.langars l where l.id = langar_id and l.status = 'approved'));
create policy "slots: owner/admin write" on public.seva_slots for all to authenticated
  using (exists (select 1 from public.langars l where l.id = langar_id and (l.submitted_by = auth.uid() or public.is_admin())))
  with check (exists (select 1 from public.langars l where l.id = langar_id and (l.submitted_by = auth.uid() or public.is_admin())));

-- signups
create policy "signups: read own or slot owner" on public.seva_signups for select to authenticated
  using (user_id = auth.uid() or public.is_admin()
         or exists (select 1 from public.seva_slots s join public.langars l on l.id = s.langar_id
                    where s.id = slot_id and l.submitted_by = auth.uid()));
create policy "signups: own write" on public.seva_signups for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- favourites
create policy "favourites: own" on public.favourites for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- reports
create policy "reports: insert" on public.reports for insert to authenticated with check (user_id = auth.uid());
create policy "reports: admin read" on public.reports for select to authenticated using (public.is_admin());

-- Public count of joined volunteers per slot (no PII). Exposed to PostgREST as a
-- computed column: `select=...,joined` on seva_slots.
create or replace function public.joined(s public.seva_slots)
returns int language sql stable security definer set search_path = public as $$
  select count(*)::int from public.seva_signups where slot_id = s.id and status = 'joined';
$$;

-- ---------- storage ----------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('langar-photos', 'langar-photos', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

create policy "photos: public read" on storage.objects for select
  using (bucket_id = 'langar-photos');
create policy "photos: authenticated upload" on storage.objects for insert to authenticated
  with check (bucket_id = 'langar-photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos: owner delete" on storage.objects for delete to authenticated
  using (bucket_id = 'langar-photos' and (storage.foldername(name))[1] = auth.uid()::text);
