# Stop two editors overwriting each other

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Turn on optimistic locking with the existing counter column via `locking_column`.

Full credit needs optimistic locking on the `revision` column. `handrolled.rb` passes the behaviour tests with a `before_update` check against the stored revision, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/Locking/Optimistic.html
