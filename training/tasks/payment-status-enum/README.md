# Preserve payment status codes and validate unknown input

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use explicit integer codes, prefixed methods and `validate: true`, so bad form input becomes a validation error instead of an exception.

Full credit needs the enum is declared with `validate: true`. `handrolled.rb` passes the behaviour tests with rescuing the enum's ArgumentError in a custom setter, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/classes/ActiveRecord/Enum.html
