-- ============================================================
-- My Stables — ALL migrations combined, in order.
-- Paste this whole file into Supabase SQL Editor and Run once.
-- Idempotent: safe to re-run.
-- ============================================================


-- >>>>>>>>>> supabase_setup.sql >>>>>>>>>>

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


-- >>>>>>>>>> supabase_setup_2_invites.sql >>>>>>>>>>

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


-- >>>>>>>>>> supabase_setup_3_schedule_tasks.sql >>>>>>>>>>

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


-- >>>>>>>>>> supabase_setup_4_horse_record.sql >>>>>>>>>>

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


-- >>>>>>>>>> supabase_setup_5_tack.sql >>>>>>>>>>

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


-- >>>>>>>>>> supabase_setup_6_contacts_documents.sql >>>>>>>>>>

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


-- >>>>>>>>>> supabase_setup_7_transport.sql >>>>>>>>>>

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


-- >>>>>>>>>> supabase_setup_8_roles_features.sql >>>>>>>>>>

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

  new_role := case when inv.role in ('Rider', '') or inv.role is null
                   then 'groom' else lower(inv.role) end;
  new_status := case when coalesce(needs_ok, false) then 'pending' else 'active' end;

  insert into public.memberships (stable_id, user_id, role, status)
  values (inv.stable_id, auth.uid(), new_role, new_status)
  on conflict (stable_id, user_id) do nothing;

  select * into s from public.stables where id = inv.stable_id;
  return s;
end;
$$;


-- >>>>>>>>>> supabase_setup_9_market.sql >>>>>>>>>>

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


-- >>>>>>>>>> supabase_setup_10_photos.sql >>>>>>>>>>

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


-- >>>>>>>>>> supabase_setup_11_shows.sql >>>>>>>>>>

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


-- >>>>>>>>>> supabase_setup_12_admin.sql >>>>>>>>>>

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


-- >>>>>>>>>> supabase_setup_13_quotes.sql >>>>>>>>>>

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

