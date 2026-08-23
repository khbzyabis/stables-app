-- ============================================================
-- My Stables — part 3: schedule activities and tasks
-- Run ONCE in Supabase (SQL Editor), after parts 1 and 2.
-- Idempotent: safe to re-run.
-- ============================================================

create table if not exists public.activities (
  id         uuid primary key default gen_random_uuid(),
  stable_id  uuid not null references public.stables(id) on delete cascade,
  title      text not null,
  kind       text not null default 'other',   -- lesson / farrier / vet / turnout / transport / show / other
  on_date    date not null,
  at_time    text,                             -- e.g. "10:00"
  duration   text,                             -- e.g. "1 hr"
  who        text,                             -- who it is for / with
  note       text,
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.tasks (
  id          uuid primary key default gen_random_uuid(),
  stable_id   uuid not null references public.stables(id) on delete cascade,
  title       text not null,
  assignee    text,                            -- who should do it
  due         text,                            -- e.g. "by Friday" or a time
  note        text,
  done        boolean not null default false,
  done_by     uuid references auth.users(id),
  created_by  uuid not null references auth.users(id) default auth.uid(),
  created_at  timestamptz not null default now()
);

alter table public.activities enable row level security;
alter table public.tasks      enable row level security;

drop policy if exists activities_all on public.activities;
create policy activities_all on public.activities
  for all
  using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));

drop policy if exists tasks_all on public.tasks;
create policy tasks_all on public.tasks
  for all
  using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));
