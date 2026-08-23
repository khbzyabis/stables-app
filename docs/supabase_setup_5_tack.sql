-- ============================================================
-- My Stables — part 5: tack box and per-horse setups
-- Run ONCE in Supabase (SQL Editor), after parts 1-4. Idempotent.
-- ============================================================

create table if not exists public.tack_items (
  id         uuid primary key default gen_random_uuid(),
  stable_id  uuid not null references public.stables(id) on delete cascade,
  owner_id   uuid not null references auth.users(id) default auth.uid(),
  group_name text not null,          -- Bridles / Nosebands / Bits / ...
  name       text not null,
  note       text,
  created_at timestamptz not null default now()
);

-- One saved setup per horse per activity; slots is a small JSON map
-- like {"bridle":"Brown snaffle bridle","noseband":"Cavesson", ...}
create table if not exists public.horse_setups (
  id         uuid primary key default gen_random_uuid(),
  horse_id   uuid not null references public.horses(id) on delete cascade,
  stable_id  uuid not null references public.stables(id) on delete cascade,
  activity   text not null,          -- Flatwork / Jumping / Hacking / Lunging
  slots      jsonb not null default '{}'::jsonb,
  updated_by uuid references auth.users(id) default auth.uid(),
  updated_at timestamptz not null default now(),
  unique (horse_id, activity)
);

alter table public.tack_items   enable row level security;
alter table public.horse_setups enable row level security;

drop policy if exists tack_all on public.tack_items;
create policy tack_all on public.tack_items
  for all using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));

drop policy if exists setups_all on public.horse_setups;
create policy setups_all on public.horse_setups
  for all using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));
