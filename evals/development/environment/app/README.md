# Expense claims API

Use `bin/rails db:prepare` and `bin/rails test`.

POST /expense_claims, PATCH /expense_claims/:id, GET /expense_claims/:id.
JSON writes nest fields under `expense_claim`. Fields are `merchant` (string),
`amount_cents` (integer cents), `incurred_on` (date), and `status` (`draft` or
`submitted`, default `draft`). Details may be absent on a draft.

Creation returns 201, editing and reading return 200, missing IDs return 404.
Validation failures return 422 with an `errors` object of field-to-message
arrays. Successful responses include the ID and all four fields.
