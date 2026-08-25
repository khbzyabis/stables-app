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
