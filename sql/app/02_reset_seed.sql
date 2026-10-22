-- Put the orders back to the starting state (use this to redo the demo)
truncate public.orders restart identity;
insert into public.orders (customer, item, status) values
  ('Table 3', 'Margherita pizza', 'received'),
  ('Table 1', 'Cheeseburger', 'cooking'),
  ('Table 5', 'Cream soda', 'received'),
  ('Takeout', 'Fried chicken box', 'done');
select id, item, status from public.orders order by id;
