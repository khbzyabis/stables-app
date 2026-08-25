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
