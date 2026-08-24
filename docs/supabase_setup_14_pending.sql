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
