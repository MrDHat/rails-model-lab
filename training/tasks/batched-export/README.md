# Export a large table without loading it all

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Iterate with `find_each` (or the other batch methods) so rows load in bounded batches.

Full credit needs a batch method (`find_each`, `find_in_batches` or `in_batches`). `handrolled.rb` passes the behaviour tests with a hand-written keyset loop, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/Batches.html
