Add account.password_reset_token and
Account.find_by_password_reset_token(token). A token finds its account for 15
minutes, then returns nil. Once the account's password_digest changes, every
earlier token must return nil too, so a used link can't be replayed. Tampered
tokens return nil. Keep the schema unchanged; don't store tokens.
