-- ============================================================
-- My Stables — part 2: profiles, invites, and joining a stable
-- Run this ONCE in Supabase (SQL Editor -> New query -> paste -> Run),
-- AFTER you have already run supabase_setup.sql.
-- Idempotent: safe to re-run.
-- ============================================================

-- ---------- Profiles ----------
-- A readable copy of each person's name/email, so members of a stable can
-- see who else is in it (the auth.users table itself is not client-readable).
create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  name       text,
  email      text,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles
  for select using (auth.role() = 'authenticated');

drop policy if exists profiles_insert on public.profiles;
create policy profiles_insert on public.profiles
  for insert with check (id = auth.uid());

drop policy if exists profiles_update on public.profiles;
create policy profiles_update on public.profiles
  for update using (id = auth.uid());

-- Fill a profile automatically whenever someone signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, email)
  values (new.id, new.raw_user_meta_data->>'name', new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Backfill anyone who signed up before this ran (e.g. your first account).
insert into public.profiles (id, name, email)
select id, raw_user_meta_data->>'name', email from auth.users
on conflict (id) do nothing;

-- ---------- Invites ----------
create table if not exists public.invites (
  id         uuid primary key default gen_random_uuid(),
  stable_id  uuid not null references public.stables(id) on delete cascade,
  code       text not null unique,
  role       text not null default 'Rider',
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

alter table public.invites enable row level security;

-- Only a member of the stable can create or view its invites.
drop policy if exists invites_insert on public.invites;
create policy invites_insert on public.invites
  for insert with check (public.is_stable_member(stable_id));

drop policy if exists invites_select on public.invites;
create policy invites_select on public.invites
  for select using (public.is_stable_member(stable_id));

-- ---------- Redeem an invite ----------
-- Runs as owner so a not-yet-member can look up the code and be added.
create or replace function public.redeem_invite(invite_code text)
returns public.stables
language plpgsql
security definer
set search_path = public
as $$
declare
  inv public.invites;
  s   public.stables;
begin
  select * into inv from public.invites where code = upper(trim(invite_code));
  if inv.id is null then
    raise exception 'That invite code is not valid.';
  end if;

  insert into public.memberships (stable_id, user_id, role)
  values (inv.stable_id, auth.uid(), inv.role)
  on conflict (stable_id, user_id) do nothing;

  select * into s from public.stables where id = inv.stable_id;
  return s;
end;
$$;
