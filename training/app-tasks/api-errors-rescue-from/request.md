When something goes wrong, the API answers with Rails' default error
responses, which the mobile app can't show. Make every API endpoint answer
client errors with JSON `{"error": MESSAGE}`:

- 404 with the message "Not found" for an unknown product, order or customer
  (including an unknown SKU in an order).
- 400 for a missing required parameter, with the exception's message, e.g.
  "param is missing or the value is empty or invalid: items".
- 422 for a record that fails validation, with the exception's message, e.g.
  "Validation failed: Quantity must be greater than 0".

A request without a valid API key still gets a bare 401.
