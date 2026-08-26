-- ============================================================
-- My Stables — part 25: platform shows (operator-created events)
-- Run ONCE in Supabase (SQL Editor). Idempotent, safe to re-run.
--
-- Operators create shows in the admin dashboard (title, venue, date,
-- details, a live status line) and publish them; riders see published
-- shows in the Market. Distinct from per-stable shows (part 11).
-- ============================================================

create table if not exists public.platform_shows (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  venue       text,
  starts_on   date,
  when_text   text,          -- freeform time, e.g. "from 8am"
  description text,          -- classes, entry info, notes
  status      text,          -- live line, e.g. "Class 2 · halfway"
  published   boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

alter table public.platform_shows enable row level security;

-- Everyone signed in can read published shows; operators see all and write.
drop policy if exists platform_shows_select on public.platform_shows;
create policy platform_shows_select on public.platform_shows
  for select using (published or public.is_app_admin());

drop policy if exists platform_shows_write on public.platform_shows;
create policy platform_shows_write on public.platform_shows
  for all using (public.is_app_admin()) with check (public.is_app_admin());
