Our address-book import treats surrounding whitespace and ASCII letter case
as insignificant in Contact.email. Normalize email immediately on assignment
and on hash-style equality lookup, so find_by(email: "  ALICE@EXAMPLE.TEST ")
finds the canonical stored contact. Reassigning an existing contact must behave
the same way. Nil must not raise, and nil or whitespace-only email must fail
presence validation. This is an explicit product rule, not a universal claim
about email address case. Email delivery validation, uniqueness and raw SQL
lookup normalization are out of scope. Keep the schema unchanged.
