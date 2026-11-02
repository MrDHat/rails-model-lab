Our address-book import treats surrounding whitespace and ASCII letter case
as insignificant in Contact.email. Assigning "  ALICE@EXAMPLE.TEST " must read
back straight away as "alice@example.test", and that is what gets stored.
find_by(email: "  ALICE@EXAMPLE.TEST ") must find the contact stored as
"alice@example.test". Reassigning an existing contact must behave
the same way. Nil must not raise, and nil or whitespace-only email must fail
presence validation. This is an explicit product rule, not a universal claim
about email address case. Email delivery validation, uniqueness and raw SQL
lookup normalization are out of scope. Keep the schema unchanged.
