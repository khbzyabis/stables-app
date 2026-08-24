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
