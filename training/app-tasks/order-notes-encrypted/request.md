Customers put allergy and health details in their order notes, and the
database backups go to a third party. Encrypt the notes at rest: the `notes`
column must never hold the text a customer wrote, while the app reads and
writes `order.notes` exactly as before, and orders without notes stay
`NULL`. Put keys for development and test in the app's config; production
will get its own keys later.
