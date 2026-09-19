-- Add book description (run in Supabase SQL Editor)

alter table public.books
  add column if not exists description text;

NOTIFY pgrst, 'reload schema';
