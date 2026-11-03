Staff accounts need passwords. Store only a bcrypt hash in password_digest.
staff.authenticate(password) returns the record when the password is right
and false otherwise. A new account needs a password, and when
password_confirmation is given it must match. Keep the schema unchanged.
