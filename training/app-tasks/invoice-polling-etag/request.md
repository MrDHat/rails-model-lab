While a patient has an invoice open, the app polls
`GET /api/invoices/:number` every few seconds, and every poll builds the
whole invoice JSON again. Let the app ask whether anything changed:

- Answer with an `ETag` and a `Last-Modified` header.
- When the app sends them back (`If-None-Match`, `If-Modified-Since`) and
  the invoice hasn't changed since, answer `304 Not Modified` with no body.
- Anything that changes what the invoice JSON shows (a payment, even a
  partial one, a new or changed line, issuing, voiding) means the next poll
  gets a 200 with the full JSON again.
