-- ============================================================
-- My Stables — part 11: shows and entries
-- Run this ONCE in Supabase (SQL Editor -> New query -> paste -> Run),
-- AFTER parts 1–10. Idempotent: safe to re-run.
--
-- Shows are stable-scoped: members of a stable see and manage its shows and
-- enter horses. An entry doubles as a start-list row.
-- ============================================================

create table if not exists public.shows (
  id         uuid primary key default gen_random_uuid(),
  stable_id  uuid not null references public.stables(id) on delete cascade,
  name       text not null,
  venue      text,
  discipline text,                              -- e.g. "1.10 m", "Dressage"
  on_date    date,
  state      text not null default 'Entries open', -- free label
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.show_entries (
  id          uuid primary key default gen_random_uuid(),
  show_id     uuid not null references public.shows(id) on delete cascade,
  horse_id    uuid references public.horses(id) on delete set null,
  horse_name  text not null,
  rider_name  text,
  class_name  text,
  at_time     text,                             -- e.g. "10:25"
  status      text not null default 'entered',  -- entered / waitlist / withdrawn
  created_by  uuid not null references auth.users(id) default auth.uid(),
  created_at  timestamptz not null default now()
);

alter table public.shows        enable row level security;
alter table public.show_entries enable row level security;

-- shows: members of the stable can read and manage.
drop policy if exists shows_all on public.shows;
create policy shows_all on public.shows
  for all
  using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));

-- entries: readable/writable by members of the show's stable.
drop policy if exists show_entries_all on public.show_entries;
create policy show_entries_all on public.show_entries
  for all
  using (exists(
    select 1 from public.shows s
    where s.id = show_id and public.is_stable_member(s.stable_id)
  ))
  with check (exists(
    select 1 from public.shows s
    where s.id = show_id and public.is_stable_member(s.stable_id)
  ));
