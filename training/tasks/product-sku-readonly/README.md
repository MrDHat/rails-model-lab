# Make a column write-once

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Mark the attribute read-only after create with `attr_readonly`.

Full credit needs `sku` listed in the model's read-only attributes. `handrolled.rb` passes the behaviour tests with a callback that restores the old value, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/ReadonlyAttributes/ClassMethods.html
