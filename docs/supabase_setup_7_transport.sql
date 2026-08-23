-- ============================================================
-- My Stables — part 7: transport requests
-- The stable's side: a request for a journey, saved and shared.
-- (Transporter quotes come from the provider app, later.)
-- Run ONCE in Supabase (SQL Editor), after parts 1-6. Idempotent.
-- ============================================================

create table if not exists public.transport_requests (
  id         uuid primary key default gen_random_uuid(),
  stable_id  uuid not null references public.stables(id) on delete cascade,
  reason     text,
  from_loc   text not null,
  to_loc     text not null,
  on_day     text,
  there_by   text,
  horses     jsonb not null default '[]'::jsonb,   -- list of horse names
  needs      jsonb not null default '[]'::jsonb,   -- list of note strings
  status     text not null default 'Waiting on quotes',
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

alter table public.transport_requests enable row level security;
drop policy if exists transport_all on public.transport_requests;
create policy transport_all on public.transport_requests
  for all using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));
