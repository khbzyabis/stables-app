
-- ####### supabase_setup.sql #######

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
  -- The creator can always read their stable (needed for the insert's
  -- RETURNING step, before their membership row exists); members can too.
  for select using (created_by = auth.uid() or public.is_stable_member(id));

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

-- ####### supabase_setup_2_invites.sql #######

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

-- ####### supabase_setup_3_schedule_tasks.sql #######

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

-- ####### supabase_setup_4_horse_record.sql #######

-- ============================================================
-- My Stables — part 4: a horse's living record
-- Health entries, training sessions, and the feed chart.
-- Run ONCE in Supabase (SQL Editor), after parts 1-3. Idempotent.
-- ============================================================

create table if not exists public.health_entries (
  id         uuid primary key default gen_random_uuid(),
  horse_id   uuid not null references public.horses(id) on delete cascade,
  stable_id  uuid not null references public.stables(id) on delete cascade,
  on_date    date not null default current_date,
  kind       text not null default 'Note',   -- Vet / Farrier / Vaccination / Note
  title      text not null,
  note       text,
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.training_sessions (
  id         uuid primary key default gen_random_uuid(),
  horse_id   uuid not null references public.horses(id) on delete cascade,
  stable_id  uuid not null references public.stables(id) on delete cascade,
  on_date    date not null default current_date,
  title      text not null,
  meta       text,                            -- e.g. "Toni · 45 min · outdoor"
  feel       text not null default 'Good',    -- Good / Easy / Tense
  detail     text,
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.feed_items (
  id         uuid primary key default gen_random_uuid(),
  horse_id   uuid not null references public.horses(id) on delete cascade,
  stable_id  uuid not null references public.stables(id) on delete cascade,
  time_of_day text not null default 'Morning', -- Morning / Midday / Evening
  item       text not null,
  amount     text,
  note       text,
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

alter table public.health_entries    enable row level security;
alter table public.training_sessions enable row level security;
alter table public.feed_items         enable row level security;

drop policy if exists health_all on public.health_entries;
create policy health_all on public.health_entries
  for all using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));

drop policy if exists training_all on public.training_sessions;
create policy training_all on public.training_sessions
  for all using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));

drop policy if exists feed_all on public.feed_items;
create policy feed_all on public.feed_items
  for all using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));

-- ####### supabase_setup_5_tack.sql #######

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

-- ####### supabase_setup_6_contacts_documents.sql #######

-- ============================================================
-- My Stables — part 6: contacts and documents (with file storage)
-- Run ONCE in Supabase (SQL Editor), after parts 1-5. Idempotent.
-- ============================================================

-- ---------- Contacts ----------
create table if not exists public.contacts (
  id         uuid primary key default gen_random_uuid(),
  stable_id  uuid not null references public.stables(id) on delete cascade,
  name       text not null,
  role       text,            -- Farrier / Vet / Dentist / Feed merchant / ...
  phone      text,
  next_note  text,            -- e.g. "Thursday 15:30 · front shoes"
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

alter table public.contacts enable row level security;
drop policy if exists contacts_all on public.contacts;
create policy contacts_all on public.contacts
  for all using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));

-- ---------- Documents (metadata) ----------
create table if not exists public.documents (
  id           uuid primary key default gen_random_uuid(),
  horse_id     uuid not null references public.horses(id) on delete cascade,
  stable_id    uuid not null references public.stables(id) on delete cascade,
  name         text not null,
  status       text not null default 'On file',
  storage_path text not null,     -- path inside the horse-docs bucket
  created_by   uuid not null references auth.users(id) default auth.uid(),
  created_at   timestamptz not null default now()
);

alter table public.documents enable row level security;
drop policy if exists documents_all on public.documents;
create policy documents_all on public.documents
  for all using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));

-- ---------- Storage bucket for the actual files ----------
insert into storage.buckets (id, name, public)
values ('horse-docs', 'horse-docs', false)
on conflict (id) do nothing;

-- Any signed-in user may upload to / read from this private bucket.
-- File paths are random UUIDs, and the readable list of documents is
-- scoped per stable by the documents table above.
drop policy if exists horse_docs_read on storage.objects;
create policy horse_docs_read on storage.objects
  for select using (bucket_id = 'horse-docs' and auth.role() = 'authenticated');

drop policy if exists horse_docs_write on storage.objects;
create policy horse_docs_write on storage.objects
  for insert with check (bucket_id = 'horse-docs' and auth.role() = 'authenticated');

drop policy if exists horse_docs_delete on storage.objects;
create policy horse_docs_delete on storage.objects
  for delete using (bucket_id = 'horse-docs' and auth.role() = 'authenticated');

-- ####### supabase_setup_7_transport.sql #######

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

-- ####### supabase_setup_8_roles_features.sql #######

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

-- ####### supabase_setup_9_market.sql #######

-- ============================================================
-- My Stables — part 9: the marketplace (vendors, products, orders)
-- Run this ONCE in Supabase (SQL Editor -> New query -> paste -> Run),
-- AFTER parts 1–8. Idempotent: safe to re-run.
--
-- The marketplace is cross-stable: any signed-in person can browse approved
-- vendors and their products, and order on behalf of a stable they belong to.
-- Anyone can become a seller by creating a vendor (they own it).
-- ============================================================

-- ---------- Vendors (sellers) ----------
create table if not exists public.vendors (
  id         uuid primary key default gen_random_uuid(),
  owner_id   uuid not null references auth.users(id) default auth.uid(),
  name       text not null,
  kind       text,                              -- e.g. Feed, Tack, Services
  city       text,
  about      text,
  approved   boolean not null default true,     -- operator gate (on by default)
  created_at timestamptz not null default now()
);

-- ---------- Products ----------
create table if not exists public.products (
  id          uuid primary key default gen_random_uuid(),
  vendor_id   uuid not null references public.vendors(id) on delete cascade,
  name        text not null,
  description text,
  category    text not null default 'Feed',
  price_aed   numeric(10,2) not null default 0,
  unit        text,                             -- e.g. "20 kg", "each"
  in_stock    boolean not null default true,
  created_at  timestamptz not null default now()
);

-- ---------- Orders ----------
create table if not exists public.orders (
  id         uuid primary key default gen_random_uuid(),
  stable_id  uuid references public.stables(id) on delete set null,
  buyer_id   uuid not null references auth.users(id) default auth.uid(),
  vendor_id  uuid not null references public.vendors(id) on delete cascade,
  status     text not null default 'pending',   -- pending/accepted/fulfilled/cancelled
  note       text,
  total_aed  numeric(10,2) not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id            uuid primary key default gen_random_uuid(),
  order_id      uuid not null references public.orders(id) on delete cascade,
  product_id    uuid references public.products(id) on delete set null,
  name          text not null,
  unit_price_aed numeric(10,2) not null default 0,
  qty           integer not null default 1
);

-- ---------- Helper: do I own this vendor? ----------
create or replace function public.owns_vendor(v uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists(
    select 1 from public.vendors x
    where x.id = v and x.owner_id = auth.uid()
  );
$$;

-- ---------- Row Level Security ----------
alter table public.vendors     enable row level security;
alter table public.products    enable row level security;
alter table public.orders      enable row level security;
alter table public.order_items enable row level security;

-- vendors: everyone signed in sees approved vendors (and their own); owner writes.
drop policy if exists vendors_select on public.vendors;
create policy vendors_select on public.vendors
  for select using (approved or owner_id = auth.uid());

drop policy if exists vendors_insert on public.vendors;
create policy vendors_insert on public.vendors
  for insert with check (owner_id = auth.uid());

drop policy if exists vendors_update on public.vendors;
create policy vendors_update on public.vendors
  for update using (owner_id = auth.uid()) with check (owner_id = auth.uid());

drop policy if exists vendors_delete on public.vendors;
create policy vendors_delete on public.vendors
  for delete using (owner_id = auth.uid());

-- products: readable when the vendor is approved (or you own it); owner writes.
drop policy if exists products_select on public.products;
create policy products_select on public.products
  for select using (
    owns_vendor(vendor_id)
    or exists(select 1 from public.vendors v
              where v.id = vendor_id and v.approved)
  );

drop policy if exists products_write on public.products;
create policy products_write on public.products
  for all using (owns_vendor(vendor_id)) with check (owns_vendor(vendor_id));

-- orders: the buyer and the vendor owner can see them.
drop policy if exists orders_select on public.orders;
create policy orders_select on public.orders
  for select using (buyer_id = auth.uid() or owns_vendor(vendor_id));

drop policy if exists orders_insert on public.orders;
create policy orders_insert on public.orders
  for insert with check (buyer_id = auth.uid());

-- buyer or vendor owner can update (buyer cancels; vendor advances status).
drop policy if exists orders_update on public.orders;
create policy orders_update on public.orders
  for update using (buyer_id = auth.uid() or owns_vendor(vendor_id))
  with check (buyer_id = auth.uid() or owns_vendor(vendor_id));

-- order_items: follow the parent order.
drop policy if exists order_items_select on public.order_items;
create policy order_items_select on public.order_items
  for select using (exists(
    select 1 from public.orders o
    where o.id = order_id
      and (o.buyer_id = auth.uid() or owns_vendor(o.vendor_id))
  ));

drop policy if exists order_items_insert on public.order_items;
create policy order_items_insert on public.order_items
  for insert with check (exists(
    select 1 from public.orders o
    where o.id = order_id and o.buyer_id = auth.uid()
  ));

-- ####### supabase_setup_10_photos.sql #######

-- ============================================================
-- My Stables — part 10: photos (horses and products)
-- Run this ONCE in Supabase (SQL Editor -> New query -> paste -> Run),
-- AFTER parts 1–9. Idempotent: safe to re-run.
--
-- Adds a public "photos" storage bucket and a URL column on horses and
-- products. Photos aren't sensitive, so the bucket is public-read (fast to
-- show, no signing); only signed-in users can upload or delete.
-- ============================================================

-- ---------- Columns ----------
alter table public.horses   add column if not exists photo_url text;
alter table public.products add column if not exists image_url text;

-- ---------- Public storage bucket ----------
insert into storage.buckets (id, name, public)
values ('photos', 'photos', true)
on conflict (id) do update set public = true;

-- Anyone can read (it's public); signed-in users can upload and delete.
drop policy if exists photos_read on storage.objects;
create policy photos_read on storage.objects
  for select using (bucket_id = 'photos');

drop policy if exists photos_write on storage.objects;
create policy photos_write on storage.objects
  for insert with check (bucket_id = 'photos' and auth.role() = 'authenticated');

drop policy if exists photos_delete on storage.objects;
create policy photos_delete on storage.objects
  for delete using (bucket_id = 'photos' and auth.role() = 'authenticated');

-- ####### supabase_setup_11_shows.sql #######

-- ============================================================
-- My Stables — part 11: shows and entries
-- Run this ONCE in Supabase (SQL Editor -> New query -> paste -> Run),
-- AFTER parts 1–10. Idempotent: safe to re-run.
--
-- Shows are stable-scoped: members of a stable see and manage its shows and
-- enter horses. An entry doubles as a start-list row.
-- ============================================================

create table if not exists public.shows (
  id         uuid primary key default gen_random_uuid(),
  stable_id  uuid not null references public.stables(id) on delete cascade,
  name       text not null,
  venue      text,
  discipline text,                              -- e.g. "1.10 m", "Dressage"
  on_date    date,
  state      text not null default 'Entries open', -- free label
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.show_entries (
  id          uuid primary key default gen_random_uuid(),
  show_id     uuid not null references public.shows(id) on delete cascade,
  horse_id    uuid references public.horses(id) on delete set null,
  horse_name  text not null,
  rider_name  text,
  class_name  text,
  at_time     text,                             -- e.g. "10:25"
  status      text not null default 'entered',  -- entered / waitlist / withdrawn
  created_by  uuid not null references auth.users(id) default auth.uid(),
  created_at  timestamptz not null default now()
);

alter table public.shows        enable row level security;
alter table public.show_entries enable row level security;

-- shows: members of the stable can read and manage.
drop policy if exists shows_all on public.shows;
create policy shows_all on public.shows
  for all
  using (public.is_stable_member(stable_id))
  with check (public.is_stable_member(stable_id));

-- entries: readable/writable by members of the show's stable.
drop policy if exists show_entries_all on public.show_entries;
create policy show_entries_all on public.show_entries
  for all
  using (exists(
    select 1 from public.shows s
    where s.id = show_id and public.is_stable_member(s.stable_id)
  ))
  with check (exists(
    select 1 from public.shows s
    where s.id = show_id and public.is_stable_member(s.stable_id)
  ));

-- ####### supabase_setup_12_admin.sql #######

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

-- ####### supabase_setup_13_quotes.sql #######

-- ============================================================
-- My Stables — part 13: quote requests (service & transport providers)
-- Run this ONCE in Supabase (SQL Editor -> New query -> paste -> Run),
-- AFTER parts 1–12. Idempotent: safe to re-run.
--
-- One table serves both flows: a stable asks a specific provider (a vendor)
-- for a price; the provider replies with a quote; the stable accepts or
-- declines. Services (farrier, vet, physio) and transport share it.
-- ============================================================

create table if not exists public.quote_requests (
  id          uuid primary key default gen_random_uuid(),
  kind        text not null default 'service',  -- 'service' | 'transport'
  stable_id   uuid references public.stables(id) on delete set null,
  buyer_id    uuid not null references auth.users(id) default auth.uid(),
  vendor_id   uuid not null references public.vendors(id) on delete cascade,
  subject     text,
  detail      text,
  -- transport specifics (null for services)
  from_loc    text,
  to_loc      text,
  on_day      text,
  horses      integer,
  -- the provider's reply
  quote_price numeric(10,2),
  quote_note  text,
  status      text not null default 'open',      -- open/quoted/accepted/declined
  created_at  timestamptz not null default now(),
  quoted_at   timestamptz
);

alter table public.quote_requests enable row level security;

-- The buyer and the provider (vendor owner) can see the request.
drop policy if exists quote_requests_select on public.quote_requests;
create policy quote_requests_select on public.quote_requests
  for select using (buyer_id = auth.uid() or public.owns_vendor(vendor_id));

-- Only the buyer creates the request.
drop policy if exists quote_requests_insert on public.quote_requests;
create policy quote_requests_insert on public.quote_requests
  for insert with check (buyer_id = auth.uid());

-- Buyer (accept/decline) and provider (add the quote) can both update.
drop policy if exists quote_requests_update on public.quote_requests;
create policy quote_requests_update on public.quote_requests
  for update using (buyer_id = auth.uid() or public.owns_vendor(vendor_id))
  with check (buyer_id = auth.uid() or public.owns_vendor(vendor_id));

-- ####### supabase_setup_14_pending.sql #######

-- ============================================================
-- My Stables — part 14: let a pending joiner see what they're waiting on
-- Run AFTER parts 1–13. Idempotent.
--
-- A pending member can't read the stable yet (RLS), so this security-definer
-- function returns just the name/role of stables they've asked to join.
-- ============================================================

create or replace function public.my_pending_requests()
returns table(stable_id uuid, stable_name text, role text, created_at timestamptz)
language sql
security definer
stable
set search_path = public
as $$
  select m.stable_id, s.name, m.role, m.created_at
  from public.memberships m
  join public.stables s on s.id = m.stable_id
  where m.user_id = auth.uid() and m.status = 'pending'
  order by m.created_at desc;
$$;

grant execute on function public.my_pending_requests() to authenticated;

-- ####### supabase_setup_15_seller_apply.sql #######

-- ============================================================
-- My Stables — part 15: seller / provider onboarding (apply → approve)
-- Run AFTER parts 1–14. Idempotent.
--
-- A person applies to sell: they pick trades, upload the required papers, and
-- accept the seller agreement. Submitting creates their shop in a PENDING state
-- (approved = false) so they can set it up while they wait; an operator reviews
-- the application in the admin console and approves or rejects it.
-- ============================================================

-- Which trades a vendor is approved for.
alter table public.vendors add column if not exists trades text[] not null default '{}';

-- ---------- Applications ----------
create table if not exists public.seller_applications (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) default auth.uid(),
  vendor_id     uuid references public.vendors(id) on delete set null,
  trading_name  text not null,
  trades        text[] not null default '{}',
  location      text,
  agreement_accepted boolean not null default false,
  status        text not null default 'submitted', -- submitted / approved / rejected
  note          text,                              -- operator's decision note
  created_at    timestamptz not null default now(),
  decided_at    timestamptz,
  decided_by    uuid references auth.users(id)
);

create table if not exists public.application_documents (
  id             uuid primary key default gen_random_uuid(),
  application_id uuid not null references public.seller_applications(id) on delete cascade,
  doc_type       text not null,       -- e.g. trade_licence, emirates_id, ...
  label          text not null,
  storage_path   text,
  status         text not null default 'uploaded',
  created_at     timestamptz not null default now()
);

alter table public.seller_applications  enable row level security;
alter table public.application_documents enable row level security;

-- Applicant sees their own; operators see all.
drop policy if exists seller_apps_select on public.seller_applications;
create policy seller_apps_select on public.seller_applications
  for select using (user_id = auth.uid() or public.is_app_admin());

drop policy if exists seller_apps_insert on public.seller_applications;
create policy seller_apps_insert on public.seller_applications
  for insert with check (user_id = auth.uid());

drop policy if exists seller_apps_update on public.seller_applications;
create policy seller_apps_update on public.seller_applications
  for update using (user_id = auth.uid() or public.is_app_admin())
  with check (user_id = auth.uid() or public.is_app_admin());

-- Documents follow their application.
drop policy if exists app_docs_all on public.application_documents;
create policy app_docs_all on public.application_documents
  for all using (exists(
    select 1 from public.seller_applications a
    where a.id = application_id
      and (a.user_id = auth.uid() or public.is_app_admin())
  )) with check (exists(
    select 1 from public.seller_applications a
    where a.id = application_id and a.user_id = auth.uid()
  ));

-- ---------- Approve / reject (operator only) ----------
create or replace function public.decide_application(app_id uuid, approve boolean, decision_note text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare a public.seller_applications;
begin
  if not public.is_app_admin() then
    raise exception 'Only an operator can decide applications.';
  end if;
  select * into a from public.seller_applications where id = app_id;
  if a.id is null then raise exception 'Application not found.'; end if;

  update public.seller_applications
    set status = case when approve then 'approved' else 'rejected' end,
        note = decision_note, decided_at = now(), decided_by = auth.uid()
    where id = app_id;

  if a.vendor_id is not null then
    update public.vendors set approved = approve where id = a.vendor_id;
  end if;
end;
$$;

grant execute on function public.decide_application(uuid, boolean, text) to authenticated;

-- ---------- Private bucket for the papers ----------
insert into storage.buckets (id, name, public)
values ('seller-docs', 'seller-docs', false)
on conflict (id) do nothing;

drop policy if exists seller_docs_read on storage.objects;
create policy seller_docs_read on storage.objects
  for select using (bucket_id = 'seller-docs' and auth.role() = 'authenticated');

drop policy if exists seller_docs_write on storage.objects;
create policy seller_docs_write on storage.objects
  for insert with check (bucket_id = 'seller-docs' and auth.role() = 'authenticated');

-- ####### supabase_setup_16_admin_console.sql #######

-- ============================================================
-- My Stables — part 16: admin console read models
-- Run AFTER parts 1–15. Idempotent.
--
-- The operator console needs to see across every stable and seller, which the
-- normal per-stable RLS deliberately prevents. These security-definer functions
-- expose platform-wide reads, each gated by is_app_admin() so only operators
-- can call them.
-- ============================================================

-- Platform KPIs for the Overview page.
create or replace function public.admin_overview()
returns json
language sql
security definer
stable
set search_path = public
as $$
  select case when public.is_app_admin() then json_build_object(
    'stables',       (select count(*) from public.stables),
    'people',        (select count(*) from public.profiles),
    'horses',        (select count(*) from public.horses),
    'apps_pending',  (select count(*) from public.seller_applications where status = 'submitted'),
    'sellers_live',  (select count(*) from public.vendors where approved),
    'sellers_total', (select count(*) from public.vendors),
    'orders_open',   (select count(*) from public.orders where status in ('pending','accepted')),
    'orders_total',  (select count(*) from public.orders)
  ) else null end;
$$;
grant execute on function public.admin_overview() to authenticated;

-- Every stable, with counts.
create or replace function public.admin_stables()
returns table(id uuid, name text, city text, people integer, horses integer, created_at timestamptz)
language sql
security definer
stable
set search_path = public
as $$
  select s.id, s.name, s.city,
    (select count(*)::int from public.memberships m where m.stable_id = s.id) as people,
    (select count(*)::int from public.horses h where h.stable_id = s.id) as horses,
    s.created_at
  from public.stables s
  where public.is_app_admin()
  order by s.created_at desc;
$$;
grant execute on function public.admin_stables() to authenticated;

-- Every seller/shop, with owner email and product count.
create or replace function public.admin_sellers()
returns table(id uuid, name text, kind text, city text, approved boolean,
              trades text[], owner_email text, products integer, created_at timestamptz)
language sql
security definer
stable
set search_path = public
as $$
  select v.id, v.name, v.kind, v.city, v.approved, v.trades,
    (select p.email from public.profiles p where p.id = v.owner_id) as owner_email,
    (select count(*)::int from public.products pr where pr.vendor_id = v.id) as products,
    v.created_at
  from public.vendors v
  where public.is_app_admin()
  order by v.created_at desc;
$$;
grant execute on function public.admin_sellers() to authenticated;

-- ####### supabase_setup_17_money.sql #######

-- ============================================================
-- My Stables — part 17: the money model
-- Run ONCE in Supabase (SQL Editor), AFTER parts 1–16. Idempotent.
--
-- What this adds, faithful to the handoff:
--   • commission_rates      operator-set % per category group (goods 8, services 5,
--                           transport 5, shows 0). Sellers can read their rate.
--   • orders money columns  subtotal / delivery / commission / net, the 14-day
--                           return window, refund + payout links. A trigger fills
--                           them authoritatively on insert (the client cannot fake
--                           the fee), and stamps delivered_at when an order is
--                           marked fulfilled.
--   • disputes              a buyer raises one inside the window (goods only —
--                           services cannot be returned); the operator arbitrates:
--                           pay the seller / refund the buyer / split it.
--   • payouts               a batch per vendor per half-month. Money is Held until
--                           the window closes, then Payable, then Paid on the 1st
--                           or 15th. run_payouts() sweeps eligible orders into a
--                           batch. Refunds come off the batch.
--
-- Money-state rule (the single source of truth — mirrored in Dart):
--   cancelled                      -> no money
--   an open dispute exists         -> held (disputed)
--   refunded in full               -> refunded
--   payout_id is set               -> paid
--   services/transport, fulfilled  -> payable (settle the day they are done)
--   goods, fulfilled, window past  -> payable
--   otherwise                      -> held
-- ============================================================

-- ---------- Commission rates (operator config) ----------
create table if not exists public.commission_rates (
  category_group text primary key,          -- goods / services / transport / shows
  label          text not null,
  detail         text,
  note           text,
  rate_pct       numeric(5,2) not null default 0,
  sort           int not null default 0,
  updated_at     timestamptz not null default now()
);

insert into public.commission_rates (category_group, label, detail, note, rate_pct, sort) values
  ('goods',     'Goods',        'Tack, feed, rugs, hoofcare',            'Taken from the item price, not the delivery', 8, 1),
  ('services',  'Services',     'Farriery, vet, physio, dentist',        'Lower — the provider carries the travel',      5, 2),
  ('transport', 'Transport',    'Journeys between yards, shows, clinics', 'On the quoted price',                         5, 3),
  ('shows',     'Show entries', 'Paid straight to the organiser',        'Pass-through · we take nothing',               0, 4)
on conflict (category_group) do nothing;

-- ---------- Payouts (one batch per vendor per half-month) ----------
create table if not exists public.payouts (
  id           uuid primary key default gen_random_uuid(),
  vendor_id    uuid not null references public.vendors(id) on delete cascade,
  period_start date not null,
  period_end   date not null,
  paid_on      date,
  sales_aed    numeric(12,2) not null default 0,   -- net of commission, before refunds
  refunds_aed  numeric(12,2) not null default 0,
  fee_aed      numeric(12,2) not null default 0,    -- commission taken this batch
  net_aed      numeric(12,2) not null default 0,    -- what lands in the bank
  status       text not null default 'due',         -- due / paid
  created_at   timestamptz not null default now()
);

-- ---------- Orders: money columns ----------
alter table public.orders add column if not exists category_group    text not null default 'goods';
alter table public.orders add column if not exists subtotal_aed      numeric(10,2);
alter table public.orders add column if not exists delivery_aed      numeric(10,2) not null default 0;
alter table public.orders add column if not exists commission_pct    numeric(5,2)  not null default 0;
alter table public.orders add column if not exists commission_aed    numeric(10,2) not null default 0;
alter table public.orders add column if not exists net_aed           numeric(10,2) not null default 0;
alter table public.orders add column if not exists delivered_at      timestamptz;
alter table public.orders add column if not exists return_window_days int not null default 14;
alter table public.orders add column if not exists refunded_aed      numeric(10,2) not null default 0;
alter table public.orders add column if not exists payout_id         uuid references public.payouts(id) on delete set null;

-- ---------- Trigger: fill the money on an order, authoritatively ----------
-- Delivery is AED 25 per seller, free to the buyer once their subtotal clears
-- AED 300. Commission is the configured rate for the order's category group,
-- taken from the goods subtotal only — never the delivery. The client sends
-- subtotal_aed + category_group; everything else is computed here.
create or replace function public.orders_fill_money()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  rate numeric(5,2);
  sub  numeric(10,2);
begin
  sub := coalesce(new.subtotal_aed, new.total_aed, 0);
  new.subtotal_aed := sub;

  select rate_pct into rate from public.commission_rates
   where category_group = new.category_group;
  rate := coalesce(rate, 0);

  new.commission_pct := rate;
  new.commission_aed := round(sub * rate / 100.0, 2);
  new.net_aed        := round(sub - new.commission_aed, 2);

  -- Delivery only applies to goods; services/transport carry their own travel.
  if new.category_group = 'goods' then
    new.delivery_aed := case when sub >= 300 then 0 else 25 end;
  else
    new.delivery_aed := 0;
  end if;

  new.total_aed := round(sub + new.delivery_aed, 2);
  return new;
end;
$$;

drop trigger if exists trg_orders_fill_money on public.orders;
create trigger trg_orders_fill_money
  before insert on public.orders
  for each row execute function public.orders_fill_money();

-- Stamp delivered_at the first time an order is marked fulfilled — this starts
-- the return window that moves the money from Held to Payable.
create or replace function public.orders_stamp_delivered()
returns trigger
language plpgsql
as $$
begin
  if new.status = 'fulfilled' and old.status is distinct from 'fulfilled'
     and new.delivered_at is null then
    new.delivered_at := now();
  end if;
  return new;
end;
$$;

drop trigger if exists trg_orders_stamp_delivered on public.orders;
create trigger trg_orders_stamp_delivered
  before update on public.orders
  for each row execute function public.orders_stamp_delivered();

-- ---------- Disputes ----------
create table if not exists public.disputes (
  id            uuid primary key default gen_random_uuid(),
  order_id      uuid not null references public.orders(id) on delete cascade,
  raised_by     uuid not null references auth.users(id) default auth.uid(),
  reason        text not null,
  buyer_says    text,
  seller_says   text,
  amount_aed    numeric(10,2) not null default 0,
  status        text not null default 'open',   -- open / decided
  decision      text,                           -- pay_seller / refund_buyer / split
  decision_note text,
  decided_by    uuid references auth.users(id),
  decided_at    timestamptz,
  created_at    timestamptz not null default now()
);

create index if not exists disputes_order_idx on public.disputes(order_id);

-- ---------- RLS ----------
alter table public.commission_rates enable row level security;
alter table public.payouts          enable row level security;
alter table public.disputes         enable row level security;

-- Rates: everyone signed in can read (a seller sees their cut); admin writes.
drop policy if exists rates_select on public.commission_rates;
create policy rates_select on public.commission_rates for select using (auth.uid() is not null);
drop policy if exists rates_write on public.commission_rates;
create policy rates_write on public.commission_rates
  for all using (public.is_app_admin()) with check (public.is_app_admin());

-- Payouts: the vendor owner sees their own; admin sees all. Writes via RPC only.
drop policy if exists payouts_select on public.payouts;
create policy payouts_select on public.payouts
  for select using (public.owns_vendor(vendor_id) or public.is_app_admin());

-- Disputes: buyer of the order, the vendor owner, or admin can see.
drop policy if exists disputes_select on public.disputes;
create policy disputes_select on public.disputes
  for select using (
    public.is_app_admin()
    or exists (select 1 from public.orders o
               where o.id = order_id
                 and (o.buyer_id = auth.uid() or public.owns_vendor(o.vendor_id)))
  );

-- The seller can add their side of the story; the buyer can amend theirs.
drop policy if exists disputes_update on public.disputes;
create policy disputes_update on public.disputes
  for update using (
    raised_by = auth.uid()
    or exists (select 1 from public.orders o
               where o.id = order_id and public.owns_vendor(o.vendor_id))
  ) with check (true);

-- (Inserts and decisions go through the RPCs below.)

-- ---------- RPC: buyer raises a return / dispute ----------
-- Goods only, inside the 14-day window, on an order the caller bought.
create or replace function public.raise_dispute(p_order uuid, p_reason text, p_buyer_says text default null)
returns public.disputes
language plpgsql
security definer
set search_path = public
as $$
declare
  o public.orders;
  d public.disputes;
begin
  select * into o from public.orders where id = p_order;
  if o.id is null then raise exception 'Order not found'; end if;
  if o.buyer_id <> auth.uid() then raise exception 'Not your order'; end if;
  if o.category_group <> 'goods' then
    raise exception 'Services cannot be returned';
  end if;
  if o.delivered_at is null then
    raise exception 'Nothing to return yet — the order has not been delivered';
  end if;
  if now() > o.delivered_at + make_interval(days => o.return_window_days) then
    raise exception 'The return window has closed';
  end if;
  if o.payout_id is not null then
    raise exception 'This order has already been paid out';
  end if;

  insert into public.disputes (order_id, reason, buyer_says, amount_aed)
  values (p_order, p_reason, p_buyer_says, o.net_aed)
  returning * into d;
  return d;
end;
$$;

-- ---------- RPC: operator arbitrates a dispute ----------
-- pay_seller  -> nothing refunded, hold releases on the normal cycle.
-- refund_buyer-> the seller's net is refunded and comes off their next payout.
-- split       -> half is refunded.
create or replace function public.decide_dispute(p_dispute uuid, p_decision text, p_note text default null)
returns public.disputes
language plpgsql
security definer
set search_path = public
as $$
declare
  d public.disputes;
  o public.orders;
  refund numeric(10,2);
begin
  if not public.is_app_admin() then raise exception 'Not authorised'; end if;
  if p_decision not in ('pay_seller','refund_buyer','split') then
    raise exception 'Unknown decision';
  end if;

  select * into d from public.disputes where id = p_dispute;
  if d.id is null then raise exception 'Dispute not found'; end if;
  select * into o from public.orders where id = d.order_id;

  refund := case p_decision
              when 'refund_buyer' then o.net_aed
              when 'split'        then round(o.net_aed / 2.0, 2)
              else 0 end;

  update public.orders set refunded_aed = refund where id = o.id;

  update public.disputes
     set status = 'decided', decision = p_decision, decision_note = p_note,
         decided_by = auth.uid(), decided_at = now()
   where id = p_dispute
   returning * into d;
  return d;
end;
$$;

-- ---------- Helper: is an order payable right now? ----------
-- Kept in SQL so the payout sweep and the admin "due" view agree exactly.
create or replace function public.order_is_payable(o public.orders)
returns boolean
language sql
stable
as $$
  select o.status <> 'cancelled'
     and o.payout_id is null
     and not exists (select 1 from public.disputes x
                     where x.order_id = o.id and x.status = 'open')
     and case
           when o.category_group in ('services','transport') then o.status = 'fulfilled'
           else o.status = 'fulfilled'
                and o.delivered_at is not null
                and now() >= o.delivered_at + make_interval(days => o.return_window_days)
         end;
$$;

-- ---------- RPC: payouts due, grouped by vendor (operator) ----------
create or replace function public.admin_payouts_due()
returns json
language sql
security definer
set search_path = public
as $$
  select coalesce(json_agg(row_to_json(t) order by (t.net_aed) desc), '[]'::json)
  from (
    select v.id as vendor_id, v.name as vendor_name, v.kind,
           coalesce(sum(o.net_aed), 0)                                as sales_aed,
           coalesce(sum(o.refunded_aed), 0)                           as refunds_aed,
           coalesce(sum(o.commission_aed), 0)                         as fee_aed,
           coalesce(sum(o.net_aed - o.refunded_aed), 0)               as net_aed,
           count(o.id)                                                as order_count,
           coalesce((select sum(h.net_aed - h.refunded_aed)
                     from public.orders h
                     where h.vendor_id = v.id and h.payout_id is null
                       and h.status <> 'cancelled'
                       and not public.order_is_payable(h)), 0)        as held_aed
    from public.vendors v
    join public.orders o on o.vendor_id = v.id and public.order_is_payable(o)
    group by v.id, v.name, v.kind
  ) t
  where public.is_app_admin();
$$;

-- ---------- RPC: run the payouts (operator, on the 1st / 15th) ----------
-- Sweeps every payable order into a per-vendor batch and marks it paid.
create or replace function public.run_payouts(p_as_of date default current_date)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v record;
  new_payout public.payouts;
  p_start date;
  p_end   date;
  batches int := 0;
  total   numeric(12,2) := 0;
begin
  if not public.is_app_admin() then raise exception 'Not authorised'; end if;

  -- Which half-month are we closing?
  if extract(day from p_as_of) < 15 then
    p_start := date_trunc('month', p_as_of - interval '1 day')::date;   -- prev month 1st
    p_end   := (date_trunc('month', p_as_of)::date - 1);                -- prev month end
  else
    p_start := date_trunc('month', p_as_of)::date;                      -- this month 1st
    p_end   := (date_trunc('month', p_as_of)::date + 13);              -- 14th
  end if;

  for v in
    select o.vendor_id,
           sum(o.net_aed)                    as sales,
           sum(o.refunded_aed)               as refunds,
           sum(o.commission_aed)             as fee,
           sum(o.net_aed - o.refunded_aed)   as net
    from public.orders o
    where public.order_is_payable(o)
    group by o.vendor_id
  loop
    insert into public.payouts (vendor_id, period_start, period_end, paid_on,
                                sales_aed, refunds_aed, fee_aed, net_aed, status)
    values (v.vendor_id, p_start, p_end, p_as_of,
            v.sales, v.refunds, v.fee, v.net, 'paid')
    returning * into new_payout;

    update public.orders o
       set payout_id = new_payout.id
     where o.vendor_id = v.vendor_id and public.order_is_payable(o);

    batches := batches + 1;
    total := total + v.net;
  end loop;

  return json_build_object('batches', batches, 'net_aed', total,
                           'period_start', p_start, 'period_end', p_end);
end;
$$;

-- ---------- RPC: set a commission rate (operator) ----------
create or replace function public.set_commission_rate(p_group text, p_rate numeric)
returns public.commission_rates
language plpgsql
security definer
set search_path = public
as $$
declare r public.commission_rates;
begin
  if not public.is_app_admin() then raise exception 'Not authorised'; end if;
  update public.commission_rates
     set rate_pct = p_rate, updated_at = now()
   where category_group = p_group
   returning * into r;
  return r;
end;
$$;

-- ---------- Grants ----------
grant execute on function public.raise_dispute(uuid, text, text)      to authenticated;
grant execute on function public.decide_dispute(uuid, text, text)     to authenticated;
grant execute on function public.admin_payouts_due()                  to authenticated;
grant execute on function public.run_payouts(date)                    to authenticated;
grant execute on function public.set_commission_rate(text, numeric)   to authenticated;

-- ####### supabase_setup_18_provider.sql #######

-- ============================================================
-- My Stables — part 18: the Provider App (the phone side for providers)
-- Run ONCE in Supabase (SQL Editor), AFTER parts 1–17. Idempotent.
--
-- The provider phone app answers one question: what am I doing next, and did I
-- get paid for the last one. It reuses vendors / orders / quote_requests and
-- adds only what the phone needs:
--   • quote_requests: a schedule date, a finishing note, a completed_at stamp,
--     and a 'completed' status (a job that is done).
--   • vendor_availability + vendor_time_away + vendors.daily_cap: "When I work".
--   • provider_threads: a plain message thread between a provider and a stable
--     (the "Chat" tab). RLS keeps it to the two sides.
-- ============================================================

-- ---------- Jobs: schedule, finishing note, completion ----------
alter table public.quote_requests add column if not exists scheduled_for date;
alter table public.quote_requests add column if not exists provider_note text;
alter table public.quote_requests add column if not exists completed_at  timestamptz;
-- status vocab is now: open / quoted / accepted / declined / completed

-- ---------- Availability ("When I work") ----------
alter table public.vendors add column if not exists daily_cap int not null default 6;

create table if not exists public.vendor_availability (
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  dow       int  not null,                 -- 0 = Sunday … 6 = Saturday
  is_open   boolean not null default true,
  primary key (vendor_id, dow)
);

create table if not exists public.vendor_time_away (
  id         uuid primary key default gen_random_uuid(),
  vendor_id  uuid not null references public.vendors(id) on delete cascade,
  start_date date not null,
  end_date   date not null,
  created_at timestamptz not null default now()
);

-- ---------- Chat: a provider <-> stable thread ----------
create table if not exists public.provider_messages (
  id         uuid primary key default gen_random_uuid(),
  vendor_id  uuid not null references public.vendors(id) on delete cascade,
  stable_id  uuid not null references public.stables(id) on delete cascade,
  sender_id  uuid not null references auth.users(id) default auth.uid(),
  body       text not null,
  created_at timestamptz not null default now()
);

create index if not exists provider_messages_thread_idx
  on public.provider_messages(vendor_id, stable_id, created_at);

-- ---------- RLS ----------
alter table public.vendor_availability enable row level security;
alter table public.vendor_time_away    enable row level security;
alter table public.provider_messages   enable row level security;

-- Availability: the owner manages it; any signed-in person can read it (a
-- stable checks before it asks).
drop policy if exists availability_select on public.vendor_availability;
create policy availability_select on public.vendor_availability
  for select using (auth.uid() is not null);
drop policy if exists availability_write on public.vendor_availability;
create policy availability_write on public.vendor_availability
  for all using (public.owns_vendor(vendor_id)) with check (public.owns_vendor(vendor_id));

drop policy if exists time_away_select on public.vendor_time_away;
create policy time_away_select on public.vendor_time_away
  for select using (auth.uid() is not null);
drop policy if exists time_away_write on public.vendor_time_away;
create policy time_away_write on public.vendor_time_away
  for all using (public.owns_vendor(vendor_id)) with check (public.owns_vendor(vendor_id));

-- Messages: the provider (vendor owner) and members of the stable can read and
-- write the thread; the sender is always the caller.
drop policy if exists provider_messages_select on public.provider_messages;
create policy provider_messages_select on public.provider_messages
  for select using (
    public.owns_vendor(vendor_id) or public.is_stable_member(stable_id)
  );

drop policy if exists provider_messages_insert on public.provider_messages;
create policy provider_messages_insert on public.provider_messages
  for insert with check (
    sender_id = auth.uid()
    and (public.owns_vendor(vendor_id) or public.is_stable_member(stable_id))
  );

-- ---------- RPC: the provider's stables (for the Chat list) ----------
-- Every stable this provider has a job or an order with, plus the last message.
create or replace function public.provider_threads(p_vendor uuid)
returns json
language sql
security definer
set search_path = public
as $$
  select coalesce(json_agg(row_to_json(t) order by t.last_at desc nulls last), '[]'::json)
  from (
    select s.id as stable_id, s.name as stable_name,
           (select max(created_at) from public.provider_messages m
             where m.vendor_id = p_vendor and m.stable_id = s.id) as last_at,
           (select body from public.provider_messages m
             where m.vendor_id = p_vendor and m.stable_id = s.id
             order by created_at desc limit 1) as last_body
    from public.stables s
    where public.owns_vendor(p_vendor)
      and (
        exists (select 1 from public.orders o
                 where o.vendor_id = p_vendor and o.stable_id = s.id)
        or exists (select 1 from public.quote_requests q
                    where q.vendor_id = p_vendor and q.stable_id = s.id)
        or exists (select 1 from public.provider_messages m
                    where m.vendor_id = p_vendor and m.stable_id = s.id)
      )
  ) t;
$$;

grant execute on function public.provider_threads(uuid) to authenticated;

-- ####### supabase_setup_19_payments.sql #######

-- ============================================================
-- My Stables — part 19: payments (provider-agnostic capture)
-- Run ONCE in Supabase (SQL Editor), AFTER parts 1–18. Idempotent.
--
-- The buyer pays My Stables at checkout; the money then flows through the
-- existing held -> payable -> payout ledger (part 17). This part adds only the
-- capture step at the front, behind a provider seam so Stripe, Telr or any
-- gateway can slot in without touching the rest of the app:
--
--   • platform_settings   one row: which provider is live, the operator's TRN,
--                         the VAT rate. Operator-editable.
--   • payments            one row per checkout (covers all the baskets/orders
--                         in that checkout). Status: created -> paid / failed /
--                         refunded. Carries the provider and its reference.
--   • orders.payment_id   links each order to the checkout that paid for it.
--
-- HOW A REAL PROVIDER PLUGS IN (important):
--   A real gateway's secret key must NEVER live in the app. The client calls
--   create_payment() to get a payment row, then hands it to the provider seam
--   (a Supabase Edge Function that holds the secret and talks to Stripe/Telr).
--   The provider's webhook — again the Edge Function, running as service_role —
--   is what flips the payment to 'paid'. See supabase/functions/README.
--   Until a provider is configured, provider='mock' and mark_payment_paid()
--   lets the buyer settle their own payment so the whole flow works end to end.
-- ============================================================

-- ---------- Platform settings (single row) ----------
create table if not exists public.platform_settings (
  id               boolean primary key default true check (id),
  payment_provider text not null default 'mock',   -- mock / stripe / telr
  trn              text,                            -- operator VAT number, on receipts
  vat_pct          numeric(5,2) not null default 5,
  updated_at       timestamptz not null default now()
);

insert into public.platform_settings (id) values (true) on conflict (id) do nothing;

-- ---------- Payments ----------
create table if not exists public.payments (
  id           uuid primary key default gen_random_uuid(),
  buyer_id     uuid not null references auth.users(id) default auth.uid(),
  stable_id    uuid references public.stables(id) on delete set null,
  amount_aed   numeric(10,2) not null,
  currency     text not null default 'AED',
  provider     text not null default 'mock',
  provider_ref text,
  status       text not null default 'created',    -- created / paid / failed / refunded
  created_at   timestamptz not null default now(),
  paid_at      timestamptz
);

alter table public.orders add column if not exists payment_id uuid
  references public.payments(id) on delete set null;

-- ---------- RLS ----------
alter table public.platform_settings enable row level security;
alter table public.payments          enable row level security;

drop policy if exists settings_select on public.platform_settings;
create policy settings_select on public.platform_settings
  for select using (auth.uid() is not null);
drop policy if exists settings_write on public.platform_settings;
create policy settings_write on public.platform_settings
  for all using (public.is_app_admin()) with check (public.is_app_admin());

-- The buyer sees their own payments; the operator sees all. Writes via RPC.
drop policy if exists payments_select on public.payments;
create policy payments_select on public.payments
  for select using (buyer_id = auth.uid() or public.is_app_admin());

-- ---------- RPC: open a payment for a checkout ----------
-- The provider is stamped from settings, not the client — so the client can
-- never claim a different gateway than the one the operator has live.
create or replace function public.create_payment(p_amount numeric, p_stable uuid default null)
returns public.payments
language plpgsql
security definer
set search_path = public
as $$
declare
  prov text;
  pay  public.payments;
begin
  if auth.uid() is null then raise exception 'Not signed in'; end if;
  if p_amount is null or p_amount <= 0 then raise exception 'Bad amount'; end if;
  select payment_provider into prov from public.platform_settings where id;
  insert into public.payments (buyer_id, stable_id, amount_aed, provider)
  values (auth.uid(), p_stable, p_amount, coalesce(prov, 'mock'))
  returning * into pay;
  return pay;
end;
$$;

-- ---------- RPC: settle a payment ----------
-- Mock only. A real provider is settled by its webhook (service_role), never
-- from the client, so this refuses to mark a non-mock payment paid.
create or replace function public.mark_payment_paid(p_payment uuid, p_ref text default null)
returns public.payments
language plpgsql
security definer
set search_path = public
as $$
declare pay public.payments;
begin
  select * into pay from public.payments where id = p_payment;
  if pay.id is null then raise exception 'Payment not found'; end if;
  if pay.buyer_id <> auth.uid() then raise exception 'Not your payment'; end if;
  if pay.provider <> 'mock' then
    raise exception 'A % payment is settled by its provider, not the app', pay.provider;
  end if;
  update public.payments
     set status = 'paid', paid_at = now(),
         provider_ref = coalesce(p_ref, 'mock-' || left(id::text, 8))
   where id = p_payment
   returning * into pay;
  return pay;
end;
$$;

-- ---------- RPC: operator sets the payment settings ----------
create or replace function public.set_payment_settings(
  p_provider text default null, p_trn text default null, p_vat numeric default null)
returns public.platform_settings
language plpgsql
security definer
set search_path = public
as $$
declare s public.platform_settings;
begin
  if not public.is_app_admin() then raise exception 'Not authorised'; end if;
  if p_provider is not null and p_provider not in ('mock','stripe','telr') then
    raise exception 'Unknown provider';
  end if;
  update public.platform_settings
     set payment_provider = coalesce(p_provider, payment_provider),
         trn              = coalesce(p_trn, trn),
         vat_pct          = coalesce(p_vat, vat_pct),
         updated_at       = now()
   where id
   returning * into s;
  return s;
end;
$$;

grant execute on function public.create_payment(numeric, uuid)          to authenticated;
grant execute on function public.mark_payment_paid(uuid, text)          to authenticated;
grant execute on function public.set_payment_settings(text, text, numeric) to authenticated;

-- ####### supabase_setup_20_portals.sql #######

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
--
-- NOTE: uses a dedicated table name (portal_accounts) to avoid colliding with
-- any pre-existing "profiles" table in the project.
-- ============================================================

-- ---------- One row per user, carrying the account type ----------
create table if not exists public.portal_accounts (
  user_id      uuid primary key references auth.users(id) on delete cascade,
  account_type text not null default 'rider'
               check (account_type in ('rider','seller','operator')),
  created_at   timestamptz not null default now()
);

alter table public.portal_accounts enable row level security;

drop policy if exists portal_accounts_select on public.portal_accounts;
create policy portal_accounts_select on public.portal_accounts
  for select using (user_id = auth.uid() or public.is_app_admin());

-- The type is set by the sign-up trigger / operator, not the client.
drop policy if exists portal_accounts_update_admin on public.portal_accounts;
create policy portal_accounts_update_admin on public.portal_accounts
  for update using (public.is_app_admin()) with check (public.is_app_admin());

-- ---------- New sign-ups get a row, typed from their portal ----------
-- The client passes account_type in the sign-up metadata; we read it here so
-- the value is written server-side (not left only in user_metadata).
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
  insert into public.portal_accounts (user_id, account_type)
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
-- Everyone gets a row. Priority: app admins -> operator; anyone who owns a
-- vendor -> seller; everyone else -> rider.
insert into public.portal_accounts (user_id, account_type)
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
    (select account_type from public.portal_accounts where user_id = auth.uid()),
    'rider');
$$;

grant execute on function public.my_account_type() to authenticated;
