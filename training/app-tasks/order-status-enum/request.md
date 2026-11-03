Order statuses are bare integers (0 placed, 1 baking, 2 ready, 3 collected,
4 cancelled), and the API takes and returns those numbers. Give them names:

- The order JSON's `status` becomes "placed", "baking", "ready", "collected"
  or "cancelled".
- `PATCH /api/orders/:id` takes `status` as one of those names. Older
  versions of the mobile app send the numbers, so keep accepting those, and
  keep the `Order::READY` style constants.
- An unknown status gets a 422 with JSON
  `{"error": "Status is not included in the list"}` and changes nothing.
- Code can find orders with `Order.ready`, `Order.baking` and so on, and ask
  `order.collected?` and the like.

The numbers stored in the database stay as they are.
