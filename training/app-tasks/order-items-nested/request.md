Customers want to change an order until the bakery starts on it. Let
`PATCH /api/orders/:id` take an `items` list instead of a status, where each
entry is one of:

- `{"id": 5, "quantity": 3}`: change that item's quantity;
- `{"id": 5, "remove": true}`: remove that item;
- `{"sku": "BAG", "quantity": 2}`: add a product at its current price.

The order's `total_cents` is recalculated, and it answers with the order
JSON. It's all or nothing: if any entry is invalid (a quantity of 0, say) it
answers 422 with JSON `{"errors": [...full error messages...]}` and changes
nothing. An item id that isn't part of this order is a 404. Only orders that
are still placed can change; any other gets a 422 with
`{"errors": ["Order can't be changed once baking has started"]}`. Status
changes work as before.
