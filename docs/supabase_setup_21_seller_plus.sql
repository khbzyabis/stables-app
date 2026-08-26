-- ============================================================
-- My Stables — part 21: seller gating + inventory
-- Run ONCE in Supabase (SQL Editor), AFTER parts 1–20. Idempotent.
--
--   • A new shop is NOT live until the operator approves it. (Belt-and-braces:
--     the default flips to false, so nothing can go live by accident.)
--   • Products get a real stock quantity for inventory tracking (nullable —
--     null means "not tracked", any number is the count on hand).
-- ============================================================

-- New vendors start unapproved; the operator flips them live in the console.
alter table public.vendors alter column approved set default false;

-- Inventory: a countable stock level (null = untracked / made to order).
alter table public.products add column if not exists stock_qty int;
