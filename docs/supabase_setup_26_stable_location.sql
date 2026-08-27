-- ============================================================
-- My Stables — part 26: stable map location
-- Run ONCE in Supabase (SQL Editor). Idempotent, safe to re-run.
--
-- Stores the pin a stable drops on the map, and whether the exact spot is
-- shown to everyone or only the area.
-- ============================================================

alter table public.stables
  add column if not exists lat             double precision,
  add column if not exists lng             double precision,
  add column if not exists location_public boolean not null default false;
