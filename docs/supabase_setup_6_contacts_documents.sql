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
