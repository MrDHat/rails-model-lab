Customers want to see their receipt online. Add a link to the receipt email
(`OrderMailer.receipt`) that opens the receipt without signing in: a page at
`/receipts/TOKEN` (`http://example.com/receipts/...` in tests) showing the
order's items, like "2 x Croissant", and its total. Since anyone with the
link can open it, the token must not be guessable or derivable from the
order's id, and a link works for 30 days. A wrong, tampered or expired token
is a 404.
