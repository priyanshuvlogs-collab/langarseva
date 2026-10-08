-- Seed: well-known langars. Run as postgres (dashboard SQL editor / MCP). Idempotent.
alter table public.langars disable trigger langars_guard_trg;

with data (name, city, state, lat, lng, address, description, kind) as (
  values
  ('Gurudwara Bangla Sahib', 'New Delhi', 'Delhi', 28.6264, 77.2090, 'Ashoka Rd, Hanuman Road Area, Connaught Place, New Delhi 110001', 'One of the largest langars in Delhi, serving thousands every day.', '24h'),
  ('Sri Harmandir Sahib (Golden Temple)', 'Amritsar', 'Punjab', 31.6200, 74.8765, 'Golden Temple Rd, Atta Mandi, Katra Ahluwalia, Amritsar 143006', 'The world''s largest free kitchen, serving around 100,000 people a day.', '24h'),
  ('Gurudwara Sis Ganj Sahib', 'Delhi', 'Delhi', 28.6562, 77.2334, 'Chandni Chowk Rd, Old Delhi 110006', 'Historic gurudwara in Chandni Chowk with a daily langar.', 'day'),
  ('Gurudwara Rakab Ganj Sahib', 'New Delhi', 'Delhi', 28.6194, 77.2032, 'Pandit Pant Marg, near Parliament House, New Delhi 110001', 'Langar served daily near Parliament.', 'day'),
  ('Gurudwara Majnu Ka Tilla', 'Delhi', 'Delhi', 28.7004, 77.2262, 'Outer Ring Rd, Majnu Ka Tilla, Delhi 110054', 'Riverside gurudwara on the Yamuna with daily langar.', 'day'),
  ('Gurudwara Nanak Piao Sahib', 'Delhi', 'Delhi', 28.7072, 77.2017, 'GT Karnal Rd, Rana Pratap Bagh, Delhi 110007', 'Where Guru Nanak offered water to travellers; langar continues the tradition.', 'day'),
  ('Takht Sri Keshgarh Sahib', 'Anandpur Sahib', 'Punjab', 31.2365, 76.5003, 'Anandpur Sahib, Rupnagar 140118', 'Birthplace of the Khalsa; large langar hall.', 'day'),
  ('Gurudwara Dukh Nivaran Sahib', 'Patiala', 'Punjab', 30.3398, 76.3869, 'Lehal, Patiala 147001', 'Daily langar, very busy on Tuesdays and Gurpurabs.', 'day'),
  ('Takht Sachkhand Sri Hazur Sahib', 'Nanded', 'Maharashtra', 19.1480, 77.3201, 'Nanded 431601', 'One of the five Takhts; langar served to all visitors.', 'day'),
  ('Takht Sri Harimandir Ji Patna Sahib', 'Patna', 'Bihar', 25.6016, 85.2311, 'Harmandir Gali, Patna City 800008', 'Birthplace of Guru Gobind Singh Ji; daily langar.', 'day'),
  ('Gurudwara Paonta Sahib', 'Paonta Sahib', 'Himachal Pradesh', 30.4397, 77.6245, 'Paonta Sahib, Sirmaur 173025', 'Gurudwara on the banks of the Yamuna with daily langar.', 'day'),
  ('Gurudwara Nada Sahib', 'Panchkula', 'Haryana', 30.7215, 76.9036, 'Nada Sahib, Panchkula 134109', 'Popular gurudwara near Chandigarh; langar all day.', 'day'),
  ('Gurudwara Ber Sahib', 'Sultanpur Lodhi', 'Punjab', 31.2168, 75.1941, 'Sultanpur Lodhi, Kapurthala 144626', 'Where Guru Nanak attained enlightenment; langar daily.', 'day'),
  ('Gurudwara Sri Fatehgarh Sahib', 'Fatehgarh Sahib', 'Punjab', 30.6446, 76.3932, 'Fatehgarh Sahib 140406', 'Memorial to the Sahibzadas; langar served daily.', 'day'),
  ('Gurudwara Sri Guru Singh Sabha, Ulsoor', 'Bengaluru', 'Karnataka', 12.9808, 77.6186, 'Kensington Rd, Ulsoor, Bengaluru 560008', 'Largest gurudwara in Bengaluru; langar at lunch and dinner.', 'meals')
)
insert into public.langars (name, city, state, lat, lng, address, description, status)
select name, city, state, lat, lng, address, description, 'approved'
from data d
where not exists (select 1 from public.langars l where l.name = d.name and l.city = d.city);

-- timings
insert into public.langar_timings (langar_id, day_of_week, opens_at, closes_at, is_24h)
select l.id, dow, null, null, true
from public.langars l, generate_series(0,6) dow
where l.name in ('Gurudwara Bangla Sahib','Sri Harmandir Sahib (Golden Temple)')
  and not exists (select 1 from public.langar_timings t where t.langar_id = l.id);

insert into public.langar_timings (langar_id, day_of_week, opens_at, closes_at, is_24h)
select l.id, dow, '06:00', '22:00', false
from public.langars l, generate_series(0,6) dow
where l.submitted_by is null
  and l.name not in ('Gurudwara Bangla Sahib','Sri Harmandir Sahib (Golden Temple)','Gurudwara Sri Guru Singh Sabha, Ulsoor')
  and not exists (select 1 from public.langar_timings t where t.langar_id = l.id);

insert into public.langar_timings (langar_id, day_of_week, opens_at, closes_at, is_24h)
select l.id, dow, s.o, s.c, false
from public.langars l, generate_series(0,6) dow,
     (values ('11:30'::time,'14:30'::time), ('19:00'::time,'21:30'::time)) s(o,c)
where l.name = 'Gurudwara Sri Guru Singh Sabha, Ulsoor'
  and not exists (select 1 from public.langar_timings t where t.langar_id = l.id);

alter table public.langars enable trigger langars_guard_trg;
