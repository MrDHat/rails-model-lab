Staff edit an order's notes from two tablets at once, and the later save
silently throws away the earlier one. Add the notes and a `version` number to
the order JSON, and let `PATCH /api/orders/:id` change the notes: a notes
change must send the `version` the tablet last saw, and if the order has
changed in any way since then the PATCH gets a 409 with JSON
`{"error": "This order was changed by someone else"}` and saves nothing. A
successful change answers with the order JSON, carrying its new version.
Status changes from the kitchen screen don't send a version and always
apply.
