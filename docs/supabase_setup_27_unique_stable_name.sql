-- ============================================================
-- My Stables — part 27: globally-unique stable names
-- Run ONCE in Supabase (SQL Editor).
--
-- Makes stable names unique across the whole platform (case-insensitive),
-- the way usernames are — nobody can create a second stable with a name
-- another stable already uses.
--
-- NOTE: if you already have two stables with the same name, this will fail
-- until you rename one. Find duplicates first with:
--
--   select lower(name) as name, count(*)
--   from public.stables
--   group by lower(name) having count(*) > 1;
--
-- then rename one, e.g.:
--
--   update public.stables set name = 'Test1 (old)' where id = '<the-id>';
-- ============================================================

create unique index if not exists stables_name_unique
  on public.stables (lower(name));
