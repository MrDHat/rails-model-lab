Project slugs appear in URLs under each account, so a slug must be unique
within its account, ignoring letter case ("Docs" and "docs" clash). Different
accounts may use the same slug. A blank slug is invalid. Saving an existing
project without changing its slug must still work. Duplicates must show up as
an ordinary validation error on slug. Keep the schema unchanged.
