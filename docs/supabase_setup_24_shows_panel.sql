-- ============================================================
-- My Stables — part 24: the Shows panel (operator-controlled)
-- Run ONCE in Supabase (SQL Editor). Idempotent, safe to re-run.
--
-- A single operator-controlled panel that the market home shows when a
-- competition is on: the weekend show's details plus a live status line
-- ("Class 2 · halfway"). Off by default — riders see nothing until an
-- operator turns it on from the admin dashboard.
-- ============================================================

alter table public.platform_settings
  add column if not exists shows_on    boolean not null default false,
  add column if not exists show_title  text,
  add column if not exists show_venue  text,
  add column if not exists show_when    text,   -- e.g. "Sat 30 Aug, from 8am"
  add column if not exists show_status text;    -- live line, e.g. "Class 2 · halfway"

-- Operator sets the panel. Passing null for a field leaves it unchanged;
-- pass shows_on explicitly to turn the panel on or off.
create or replace function public.set_shows_panel(
  p_on      boolean default null,
  p_title   text    default null,
  p_venue   text    default null,
  p_when    text    default null,
  p_status  text    default null)
returns public.platform_settings
language plpgsql
security definer
set search_path = public
as $$
declare s public.platform_settings;
begin
  if not public.is_app_admin() then raise exception 'Not authorised'; end if;
  update public.platform_settings
     set shows_on    = coalesce(p_on, shows_on),
         show_title  = coalesce(p_title, show_title),
         show_venue  = coalesce(p_venue, show_venue),
         show_when   = coalesce(p_when, show_when),
         show_status = coalesce(p_status, show_status),
         updated_at  = now()
   where id
   returning * into s;
  return s;
end;
$$;

grant execute on function public.set_shows_panel(boolean, text, text, text, text)
  to authenticated;
