-- Run this in Supabase → SQL Editor → New query → Run

create table if not exists public.books (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  author text not null default '',
  section text not null default '',
  shelf text not null,
  position int not null,
  barcode text,
  description text,
  status text not null default 'available'
    check (status in ('available', 'borrowed', 'missing')),
  missing_note text,
  missing_reported_at timestamptz,
  created_at timestamptz not null default now()
);

create unique index if not exists books_barcode_key
  on public.books (barcode)
  where barcode is not null;

alter table public.books enable row level security;

-- Demo policies: allow public read/update with anon key
create policy "Allow public read books"
  on public.books for select
  to anon, authenticated
  using (true);

create policy "Allow public update books"
  on public.books for update
  to anon, authenticated
  using (true)
  with check (true);

create policy "Allow public insert books"
  on public.books for insert
  to anon, authenticated
  with check (true);

-- Sample data for demo
insert into public.books (title, author, section, shelf, position, status) values
  ('Grade 10 Chemistry', 'NCERT', 'Science', 'S-03', 12, 'available'),
  ('World History', 'A. Smith', 'History', 'S-01', 4, 'borrowed'),
  ('Algebra Basics', 'R. Khan', 'Math', 'S-02', 8, 'missing'),
  ('English Grammar', 'Wren & Martin', 'Language', 'S-01', 15, 'available'),
  ('Introduction to Physics', 'H. C. Verma', 'Science', 'S-03', 3, 'available');
