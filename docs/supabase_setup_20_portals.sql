-- ============================================================
-- My Stables — part 20: portals & account types (three front doors)
-- Run ONCE in Supabase (SQL Editor), AFTER parts 1–19. Idempotent.
--
-- The one app now has three entry URLs that must not blur together:
--   /       the rider app     -> account_type 'rider'
--   /sell   seller & provider -> account_type 'seller'
--   /admin  operator console  -> app admins only
--
-- Accounts are kept separate: every user carries an account_type, stamped at
-- sign-up from the portal they used. Sign-in checks the type against the door.
-- (One email = one account; someone who is both a rider and a seller uses two
-- emails — that is the "fully separate accounts" choice.)
-- ============================================================

-- ---------- Profiles: one row per user, carrying the account type ----------
create table if not exists public.profiles (
  user_id      uuid primary key references auth.users(id) on delete cascade,
  account_type text not null default 'rider'
               check (account_type in ('rider','seller','operator')),
  created_at   timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles
  for select using (user_id = auth.uid() or public.is_app_admin());

-- The type is set by the sign-up trigger / operator, not the client.
drop policy if exists profiles_update_admin on public.profiles;
create policy profiles_update_admin on public.profiles
  for update using (public.is_app_admin()) with check (public.is_app_admin());

-- ---------- New sign-ups get a profile, typed from their portal ----------
-- The client passes account_type in the sign-up metadata; we read it here so
-- the value is written server-side on the row (not left only in user_metadata).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  t text;
begin
  t := coalesce(nullif(new.raw_user_meta_data->>'account_type', ''), 'rider');
  if t not in ('rider','seller','operator') then t := 'rider'; end if;
  insert into public.profiles (user_id, account_type)
  values (new.id, t)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists trg_handle_new_user on auth.users;
create trigger trg_handle_new_user
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- Backfill existing users ----------
-- Everyone gets a profile. Priority: app admins -> operator; anyone who owns a
-- vendor -> seller; everyone else -> rider.
insert into public.profiles (user_id, account_type)
select u.id,
       case
         when exists (select 1 from public.app_admins a where a.user_id = u.id)
              then 'operator'
         when exists (select 1 from public.vendors v where v.owner_id = u.id)
              then 'seller'
         else 'rider'
       end
from auth.users u
on conflict (user_id) do nothing;

-- ---------- RPC: my account type (for the client's portal gate) ----------
create or replace function public.my_account_type()
returns text
language sql
security definer
set search_path = public
as $$
  select coalesce(
    (select account_type from public.profiles where user_id = auth.uid()),
    'rider');
$$;

grant execute on function public.my_account_type() to authenticated;
