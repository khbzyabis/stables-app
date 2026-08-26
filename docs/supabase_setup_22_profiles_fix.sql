-- ============================================================
-- My Stables — part 22: restore profile creation on signup
-- Run ONCE in Supabase (SQL Editor). Idempotent, safe to re-run.
--
-- Why: part 20 (portals) replaced handle_new_user so it only filled
-- portal_accounts and stopped creating a public.profiles row. Members,
-- task assignees and notice authors read names/emails from profiles, so
-- anyone who signed up after part 20 showed up blank. This makes the
-- trigger fill BOTH tables, backfills the gap, and drops the duplicate
-- trigger left behind by part 2.
-- ============================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  t text;
begin
  -- 1) Profile row (name + email) — what the app reads for people.
  insert into public.profiles (id, name, email)
  values (new.id, new.raw_user_meta_data->>'name', new.email)
  on conflict (id) do nothing;

  -- 2) Portal account type (rider / seller / operator) for the front doors.
  t := coalesce(nullif(new.raw_user_meta_data->>'account_type', ''), 'rider');
  if t not in ('rider','seller','operator') then t := 'rider'; end if;
  insert into public.portal_accounts (user_id, account_type)
  values (new.id, t)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

-- One trigger only. Part 2 created on_auth_user_created; part 20 created
-- trg_handle_new_user. Drop the old one so the function fires once.
drop trigger if exists on_auth_user_created on auth.users;
drop trigger if exists trg_handle_new_user on auth.users;
create trigger trg_handle_new_user
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Backfill profiles for anyone who signed up while the trigger was
-- only writing portal_accounts.
insert into public.profiles (id, name, email)
select id, raw_user_meta_data->>'name', email
from auth.users
on conflict (id) do nothing;
