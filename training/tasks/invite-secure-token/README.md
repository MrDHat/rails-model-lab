# Give invites a random unique code

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `has_secure_token`, which generates the code on create and adds a regenerate method the new name can wrap.

Full credit needs a call to `has_secure_token`. `handrolled.rb` passes the behaviour tests with a `before_create` callback using SecureRandom, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/SecureToken/ClassMethods.html
