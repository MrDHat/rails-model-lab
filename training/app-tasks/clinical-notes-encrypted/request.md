Clinical notes hold patients' health details, and the nightly database
backups go to an outside company. Encrypt notes at rest: the
`clinical_notes.body` column must never hold the text a practitioner wrote,
while the app reads, writes and signs notes exactly as before.

The notes written so far are in the column as plain text and have to stay
readable (we'll re-encrypt them in a later job). Saving one of them again
stores it encrypted.

Put keys for development and test in the app's config; production will get
its own keys later.
