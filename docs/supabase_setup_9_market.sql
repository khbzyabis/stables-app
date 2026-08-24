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
