-- ============================================================
-- My Stables — database setup
-- Run this ONCE in Supabase: Dashboard -> SQL Editor -> New query
-- -> paste all of this -> Run.
-- It creates the tables the app saves to, and Row Level Security
-- so each person only sees data for stables they belong to.
-- Safe to re-run: it uses "if not exists" / "or replace".
-- ============================================================

-- ---------- Tables ----------

create table if not exists public.stables (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  city       text,
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.memberships (
  id         uuid primary key default gen_random_uuid(),
  stable_id  uuid not null references public.stables(id) on delete cascade,
  user_id    uuid not null references auth.users(id) default auth.uid(),
  role       text not null default 'Admin',
  created_at timestamptz not null default now(),
  unique (stable_id, user_id)
);

create table if not exists public.horses (
  id         uuid primary key default gen_random_uuid(),
  stable_id  uuid not null references public.stables(id) on delete cascade,
  name       text not null,
  age        text,
  breed      text,
  sex        text,
  height     text,
  box        text,
  notes      text,
  status     text not null default 'well',
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.notices (
  id          uuid primary key default gen_random_uuid(),
  stable_id   uuid not null references public.stables(id) on delete cascade,
  body        text not null,
  title       text,
  pinned      boolean not null default false,
  author_id   uuid not null references auth.users(id) default auth.uid(),
  author_name text,
  created_at  timestamptz not null default now()
);

-- ---------- Helper (breaks RLS recursion) ----------
-- Runs as owner, so it can read memberships without triggering the
-- memberships policy again.
create or replace function public.is_stable_member(s uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists(
    select 1 from public.memberships m
    where m.stable_id = s and m.user_id = auth.uid()
  );
$$;

-- ---------- Row Level Security ----------
alter table public.stables     enable row level security;
alter table public.memberships enable row level security;
alter table public.horses      enable row level security;
alter table public.notices     enable row level security;

-- stables: you can create one; you can see the ones you belong to.
drop policy if exists stables_insert on public.stables;
create policy stables_insert on public.stables
  for insert with check (created_by = auth.uid());

drop policy if exists stables_select on public.stables;
create policy stables_select on public.stables
  for select using (public.is_stable_member(id));

-- memberships: you can add yourself; you can see members of your stables.
drop policy if exists memberships_insert on public.memberships;
create policy memberships_insert on public.memberships
  for insert with check (user_id = auth.uid());

drop policy if exists memberships_select on public.memberships;
create policy memberships_select on public.memberships
  for select using (user_id = auth.uid() or public.is_stable_member(stable_id));

-- horses: only members of the stable can read or add.
drop policy if exists horses_all on public.horses;
create policy horses_all on public.horses
  for all
  using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));

-- notices: only members of the stable can read or post.
drop policy if exists notices_all on public.notices;
create policy notices_all on public.notices
  for all
  using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));
