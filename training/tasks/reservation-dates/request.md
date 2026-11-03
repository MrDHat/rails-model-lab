Our equipment rental form sometimes stores reservations with no dates or a
return date before pickup. Fix Reservation so pickup_on and return_on are
required dates and return_on must be strictly later than pickup_on, reported
as an error on return_on. Same-day returns are not supported. Apply the rule
to both new and existing records. Missing or unreadable dates must produce
ordinary validation errors and never raise.
Keep the schema and public attribute names unchanged.
