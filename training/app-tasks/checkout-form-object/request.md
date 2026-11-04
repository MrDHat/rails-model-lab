`POST /api/orders` stops at the first problem it trips over, with a 400, a
404 or a crash, so the mobile app can't tell customers what to fix. Check the
whole request first and, if anything is wrong, answer 422 with every problem
at once, by field, as JSON like
`{"errors": {"customer_email": ["is not a customer"], "items": ["has a quantity outside 1 to 20"]}}`,
creating nothing. The messages:

- `customer_email`: "can't be blank" when missing, "is not a customer" when
  no customer has it.
- `items`: "can't be blank" when there are none, "has an unknown product: XYZ"
  for each SKU that isn't an available product, and "has a quantity outside
  1 to 20" if any quantity isn't a whole number from 1 to 20.
- `pickup_at`, which is optional: "is not a valid time" unless it's an ISO
  8601 time.

A valid request creates the order as now, through `Order.place!`.
