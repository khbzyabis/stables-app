-- ============================================================
-- My Stables — part 4: a horse's living record
-- Health entries, training sessions, and the feed chart.
-- Run ONCE in Supabase (SQL Editor), after parts 1-3. Idempotent.
-- ============================================================

create table if not exists public.health_entries (
  id         uuid primary key default gen_random_uuid(),
  horse_id   uuid not null references public.horses(id) on delete cascade,
  stable_id  uuid not null references public.stables(id) on delete cascade,
  on_date    date not null default current_date,
  kind       text not null default 'Note',   -- Vet / Farrier / Vaccination / Note
  title      text not null,
  note       text,
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.training_sessions (
  id         uuid primary key default gen_random_uuid(),
  horse_id   uuid not null references public.horses(id) on delete cascade,
  stable_id  uuid not null references public.stables(id) on delete cascade,
  on_date    date not null default current_date,
  title      text not null,
  meta       text,                            -- e.g. "Toni · 45 min · outdoor"
  feel       text not null default 'Good',    -- Good / Easy / Tense
  detail     text,
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.feed_items (
  id         uuid primary key default gen_random_uuid(),
  horse_id   uuid not null references public.horses(id) on delete cascade,
  stable_id  uuid not null references public.stables(id) on delete cascade,
  time_of_day text not null default 'Morning', -- Morning / Midday / Evening
  item       text not null,
  amount     text,
  note       text,
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

alter table public.health_entries    enable row level security;
alter table public.training_sessions enable row level security;
alter table public.feed_items         enable row level security;

drop policy if exists health_all on public.health_entries;
create policy health_all on public.health_entries
  for all using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));

drop policy if exists training_all on public.training_sessions;
create policy training_all on public.training_sessions
  for all using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));

drop policy if exists feed_all on public.feed_items;
create policy feed_all on public.feed_items
  for all using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));
