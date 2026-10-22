-- Table for the live order board. The database holds the "current state"; Realtime only says "something changed".
-- (The tic-tac-toe in the previous article used Broadcast only, which keeps no state, so a late joiner saw an empty board.)
create table if not exists public.orders (
  id bigint primary key generated always as identity,
  customer text not null,
  item text not null,
  status text not null default 'received' check (status in ('received', 'cooking', 'done')),
  updated_by text,
  updated_at timestamptz not null default now()
);
alter table public.orders enable row level security;

-- * DEMO ONLY: allow reading, adding and updating without login (anon).
--   In a real app, allow only logged-in users (authenticated) and restrict which columns and rows can be updated.
create policy "demo: anyone can read orders" on public.orders for select to anon, authenticated using (true);
create policy "demo: anyone can add orders" on public.orders for insert to anon, authenticated with check (true);
create policy "demo: anyone can update orders" on public.orders for update to anon, authenticated using (true) with check (true);

-- Add the table to the publication that Realtime (postgres_changes) streams from
alter publication supabase_realtime add table public.orders;

-- Fake sample data
insert into public.orders (customer, item, status) values
  ('Table 3', 'Margherita pizza', 'received'),
  ('Table 1', 'Cheeseburger', 'cooking'),
  ('Table 5', 'Cream soda', 'received'),
  ('Takeout', 'Fried chicken box', 'done');
