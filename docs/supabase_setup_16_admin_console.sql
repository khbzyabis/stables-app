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
