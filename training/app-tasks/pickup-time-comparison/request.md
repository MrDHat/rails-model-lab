The mobile app lets customers pick a pickup time in the past, or months
ahead. An order's `pickup_at`, when it has one, must be after its
`placed_at` and no more than 7 days after it, with the errors
"Pickup at must be after the order is placed" and "Pickup at must be within
7 days of the order". `POST /api/orders` with a bad pickup time gets a 422
with JSON `{"errors": [...the full error messages...]}` and creates nothing.
Orders without a pickup time are still fine.
