The bakery is in Paris, but the admin's day view (`/admin/orders?day=2026-03-03`)
picks orders by UTC day: an order placed at 00:30 on 3 March in Paris shows
up under 2 March. Make each day's list hold exactly the orders placed on that
day in Paris, all year round.
