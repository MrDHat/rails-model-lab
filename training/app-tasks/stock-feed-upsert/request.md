The warehouse system will post stock levels every few minutes for the whole
catalogue, thousands of products at a time:
`POST /api/stock` with JSON
`{"products": [{"sku": "CRO", "name": "Croissant", "price_cents": 140, "stock": 35}, ...]}`.

- A known SKU gets its stock set to the feed's number. Its name, price and
  active flag stay as they are, whatever the feed says.
- An unknown SKU becomes a new, inactive product with the feed's name, price
  and stock, for staff to review before it goes on sale.
- Changed products' `updated_at` moves on (the product cache depends on it).

It answers `{"received": N}` with the number of feed rows. It has to write
everything with a single SQL statement, however many rows the feed has.
