-- ============================================================
-- My Stables — part 23: shop cover / logo image
-- Run ONCE in Supabase (SQL Editor). Idempotent, safe to re-run.
--
-- Adds an image_url to vendors so a shop can show a cover/logo on its
-- storefront and in the market home. Images live in the existing public
-- "photos" bucket (folder: shops), so no new bucket or policy is needed.
-- ============================================================

alter table public.vendors
  add column if not exists image_url text;
