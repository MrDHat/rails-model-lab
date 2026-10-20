Our equipment rental form sometimes stores reservations with no dates or a
return date before pickup. Fix Reservation so pickup_on and return_on are
required dates and return_on must be strictly later than pickup_on. Same-day
returns are not supported. Apply the rule to both new and existing records.
Bad dates must produce ordinary validation errors, not comparison exceptions.
Keep the schema and public attribute names unchanged.
