# Count views without losing updates

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Increment in the database with `increment_counter`, `update_counters` or `increment!` instead of read-modify-write.

Full credit needs `increment_counter`, `update_counters` or `increment!`. `handrolled.rb` passes the behaviour tests with raw SQL in `update_all`, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/CounterCache/ClassMethods.html
- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/Persistence.html
