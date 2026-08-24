-- ============================================================
-- My Stables — part 8: roles, approvals, and per-stable feature toggles
-- Run this ONCE in Supabase (SQL Editor -> New query -> paste -> Run),
-- AFTER parts 1–7. Idempotent: safe to re-run.
--
-- What it adds:
--   * A clear role vocabulary: owner, manager, groom, vet, viewer
--   * A membership "status" (active / pending) so joins can need approval
--   * is_stable_admin() so owners/managers can manage members & settings
--   * A stable_features table to turn modules on/off per stable
-- ============================================================

-- ---------- Memberships: status + role vocabulary ----------
alter table public.memberships
  add column if not exists status text not null default 'active';

-- New members default to the lightest useful role; the stable creator is owner.
alter table public.memberships alter column role set default 'groom';

-- Backfill: the person who created each stable is its owner. Old 'Admin' rows
-- (and the creator's row) become 'owner'.
update public.memberships m
set role = 'owner'
from public.stables s
where m.stable_id = s.id
  and m.user_id = s.created_by
  and m.role in ('Admin', 'owner', 'groom');

update public.memberships
set role = 'owner'
where role = 'Admin';

-- ---------- Helpers ----------
-- Membership now means an ACTIVE membership (pending members can't see data yet).
create or replace function public.is_stable_member(s uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists(
    select 1 from public.memberships m
    where m.stable_id = s and m.user_id = auth.uid() and m.status = 'active'
  );
$$;

-- An admin is an active owner or manager of the stable. Security definer so it
-- can read memberships without tripping the memberships policy.
create or replace function public.is_stable_admin(s uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists(
    select 1 from public.memberships m
    where m.stable_id = s and m.user_id = auth.uid()
      and m.status = 'active' and m.role in ('owner', 'manager')
  );
$$;

-- ---------- Memberships: let admins manage roles & approvals ----------
-- Admins can change a member's role or approve a pending join.
drop policy if exists memberships_update on public.memberships;
create policy memberships_update on public.memberships
  for update
  using (public.is_stable_admin(stable_id))
  with check (public.is_stable_admin(stable_id));

-- Admins can remove members; anyone can remove themselves (leave a stable).
drop policy if exists memberships_delete on public.memberships;
create policy memberships_delete on public.memberships
  for delete
  using (public.is_stable_admin(stable_id) or user_id = auth.uid());

-- ---------- Per-stable feature toggles ----------
create table if not exists public.stable_features (
  stable_id        uuid primary key references public.stables(id) on delete cascade,
  market           boolean not null default true,
  transport        boolean not null default true,
  shows            boolean not null default true,
  require_approval boolean not null default false,
  updated_at       timestamptz not null default now()
);

alter table public.stable_features enable row level security;

-- Any member can read which features are on; only admins can change them.
drop policy if exists stable_features_select on public.stable_features;
create policy stable_features_select on public.stable_features
  for select using (public.is_stable_member(stable_id));

drop policy if exists stable_features_write on public.stable_features;
create policy stable_features_write on public.stable_features
  for all
  using (public.is_stable_admin(stable_id))
  with check (public.is_stable_admin(stable_id));

-- Give every existing stable a default (all-on) feature row.
insert into public.stable_features (stable_id)
select id from public.stables
on conflict (stable_id) do nothing;

-- ---------- Redeem an invite (approval-aware) ----------
-- Adds the invite's role, and sets status to 'pending' when the stable requires
-- approval, otherwise 'active'. Maps the old 'Rider' default to 'groom'.
create or replace function public.redeem_invite(invite_code text)
returns public.stables
language plpgsql
security definer
set search_path = public
as $$
declare
  inv        public.invites;
  s          public.stables;
  needs_ok   boolean;
  new_role   text;
  new_status text;
begin
  select * into inv from public.invites where code = upper(trim(invite_code));
  if inv.id is null then
    raise exception 'That invite code is not valid.';
  end if;

  select coalesce(require_approval, false) into needs_ok
  from public.stable_features where stable_id = inv.stable_id;

  -- Store exactly the role the invite carries (lowercased); default to groom
  -- only when the invite has no role at all.
  new_role := coalesce(nullif(lower(trim(inv.role)), ''), 'groom');
  new_status := case when coalesce(needs_ok, false) then 'pending' else 'active' end;

  insert into public.memberships (stable_id, user_id, role, status)
  values (inv.stable_id, auth.uid(), new_role, new_status)
  on conflict (stable_id, user_id) do nothing;

  select * into s from public.stables where id = inv.stable_id;
  return s;
end;
$$;
