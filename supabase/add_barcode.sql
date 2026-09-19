-- Add barcode support (run in Supabase SQL Editor)

alter table public.books
  add column if not exists barcode text;

create unique index if not exists books_barcode_key
  on public.books (barcode)
  where barcode is not null;

-- Sample barcodes for existing demo books (by title)
update public.books set barcode = '8901001000001' where title = 'Grade 10 Chemistry' and barcode is null;
update public.books set barcode = '8901001000002' where title = 'World History' and barcode is null;
update public.books set barcode = '8901001000003' where title = 'Algebra Basics' and barcode is null;
update public.books set barcode = '8901001000004' where title = 'English Grammar' and barcode is null;
update public.books set barcode = '8901001000005' where title = 'Introduction to Physics' and barcode is null;
