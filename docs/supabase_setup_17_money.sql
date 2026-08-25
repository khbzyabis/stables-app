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
