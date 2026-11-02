Newsletter.subscribe(email) returns the subscription for that email,
creating it if needed. Signups often arrive twice at the same moment, so it
must never raise because the email already exists (the unique index is the
source of truth). Keep the schema unchanged.
