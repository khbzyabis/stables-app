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
