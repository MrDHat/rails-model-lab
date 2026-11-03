# Issue expiring password-reset tokens

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `generates_token_for` with an expiry and a block, so tokens expire and die when the password changes.

Full credit needs a `password_reset` token definition from `generates_token_for`. `handrolled.rb` passes the behaviour tests with a hand-built MessageVerifier, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/TokenFor/ClassMethods.html
