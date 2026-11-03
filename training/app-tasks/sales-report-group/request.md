Add a sales report for the bakery at
`GET /admin/sales?from=2026-03-01&to=2026-03-31`: a table with a row per
product sold in that period (Paris days, both ends included), giving the
product name, the units sold and the revenue (quantity times the price paid,
shown like "€2.80"), highest revenue first. Cancelled orders don't count.
There are millions of order items, so the database has to do the adding up:
the report must not load order items into the app.
