The order editor loads an order, changes quantities on some existing line
items in memory, then calls order.save. Those changes are currently lost.
order.save must save changed line items, and if any line item is invalid
(quantity must be a positive integer) the order save must return false with
an error on the order and save nothing. Keep the schema unchanged.
