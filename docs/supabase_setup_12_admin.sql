-- ============================================================
-- My Stables — part 12: operator/admin console
-- Run this ONCE in Supabase (SQL Editor -> New query -> paste -> Run),
-- AFTER parts 1–11. Idempotent: safe to re-run.
--
-- Adds platform operators (app_admins), a global announcements board
-- ("From My Stables"), and turns on vendor approval so new shops are
-- reviewed by an operator before they appear in the marketplace.
--
-- IMPORTANT — make yourself an operator after running this. Run ONE of:
--   insert into public.app_admins (user_id)
--   select id from auth.users where email = 'you@example.com'
--   on conflict do nothing;
-- (use your own login email)
-- ============================================================

-- ---------- Platform operators ----------
create table if not exists public.app_admins (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.app_admins enable row level security;

-- Any signed-in user can read the admin list (so the app can tell if it should
-- show the console). Membership is managed in SQL, not from the client.
drop policy if exists app_admins_select on public.app_admins;
create policy app_admins_select on public.app_admins
  for select using (auth.role() = 'authenticated');

-- Am I an operator? Security definer so it never trips RLS.
create or replace function public.is_app_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists(
    select 1 from public.app_admins a where a.user_id = auth.uid()
  );
$$;

-- ---------- Announcements ("From My Stables") ----------
create table if not exists public.announcements (
  id         uuid primary key default gen_random_uuid(),
  title      text not null,
  body       text not null,
  kind       text not null default 'Update',   -- Update / Show / Advert
  active     boolean not null default true,
  pinned     boolean not null default false,
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

alter table public.announcements enable row level security;

-- Everyone signed in reads announcements; only operators write them.
drop policy if exists announcements_select on public.announcements;
create policy announcements_select on public.announcements
  for select using (auth.role() = 'authenticated');

drop policy if exists announcements_write on public.announcements;
create policy announcements_write on public.announcements
  for all using (public.is_app_admin()) with check (public.is_app_admin());

-- ---------- Vendor approval ----------
-- New shops now start unapproved and stay hidden from the marketplace until an
-- operator approves them. (Existing shops keep their current approved value.)
alter table public.vendors alter column approved set default false;

-- Operators can see every vendor (including unapproved ones awaiting review)
-- and approve/suspend any of them. These add to the existing owner/approved
-- policies (Postgres ORs permissive policies together).
drop policy if exists vendors_admin_select on public.vendors;
create policy vendors_admin_select on public.vendors
  for select using (public.is_app_admin());

drop policy if exists vendors_admin_update on public.vendors;
create policy vendors_admin_update on public.vendors
  for update using (public.is_app_admin()) with check (public.is_app_admin());
