InvoiceLine receives unit_price as a decimal string and quantity as a positive
whole number. Require a nonnegative unit_price and a positive integer quantity;
blank inputs must fail validation. Preserve the schema's four decimal places
in unit_price and round only the final subtotal to two decimal places, using
half-up rounding. subtotal must return BigDecimal, not Float, for valid lines.
For example, a price of 0.335 and quantity 3 must produce 1.01. Fractional
quantities must be rejected rather than silently accepted after casting.
Do not change the supplied schema. subtotal on invalid lines is out of scope.
