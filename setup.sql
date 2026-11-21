-- Roadkill Map: one-time database setup.
-- Paste this whole file into the Supabase SQL editor and run it once.

create table public.sightings (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  seen_at     timestamptz not null default now(),
  -- Roughly the DFW area. Widen these two checks (and BOUNDS in index.html) when you expand.
  lat         double precision not null check (lat between 32.5 and 33.4),
  lng         double precision not null check (lng between -97.7 and -96.5),
  animal      text not null check (char_length(animal) between 1 and 30),
  note        text check (note is null or char_length(note) <= 200),
  -- SHA-256 of the private key kept on the phone that added the pin. Never readable by visitors.
  device_hash text check (device_hash is null or device_hash ~ '^[0-9a-f]{64}$')
);

create index sightings_seen_at_idx on public.sightings (seen_at desc);

-- Lock the table down, then allow exactly two things for visitors: read and add.
alter table public.sightings enable row level security;

create policy "Anyone can read reports"
  on public.sightings for select to anon
  using (true);

create policy "Anyone can add a report"
  on public.sightings for insert to anon
  with check (seen_at <= now() + interval '1 day' and seen_at >= '2020-01-01');

-- Column-level grants: visitors can read every column except device_hash,
-- so nobody can tell which pins came from the same phone. No update, no direct delete.
revoke all on public.sightings from anon, authenticated;
grant select (id, created_at, seen_at, lat, lng, animal, note) on public.sightings to anon;
grant insert (seen_at, lat, lng, animal, note, device_hash) on public.sightings to anon;

-- Lets a phone remove only the pins it added itself.
-- The app keeps a private key on the phone; the table stores only its SHA-256 hash.
create or replace function public.delete_sighting(p_id uuid, p_key text)
returns boolean
language sql
security definer
set search_path = ''
as $$
  with gone as (
    delete from public.sightings
    where id = p_id
      and device_hash = encode(sha256(convert_to(p_key, 'UTF8')), 'hex')
    returning 1
  )
  select exists (select 1 from gone);
$$;

revoke all on function public.delete_sighting(uuid, text) from public, anon, authenticated;
grant execute on function public.delete_sighting(uuid, text) to anon;
