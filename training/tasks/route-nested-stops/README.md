# Handle blank and deleted nested delivery stops

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `reject_if: :all_blank` and `allow_destroy: true`, and keep child validation so meaningful invalid rows aren't silently dropped.

Full credit needs the built-in `:all_blank` rule and `allow_destroy`. `handrolled.rb` passes the behaviour tests with a lambda that re-implements `:all_blank`, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.0/classes/ActiveRecord/NestedAttributes/ClassMethods.html
