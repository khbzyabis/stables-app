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
