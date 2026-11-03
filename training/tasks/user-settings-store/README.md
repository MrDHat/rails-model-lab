# Read and write settings kept in a JSON column

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Declare store accessors so keys in the JSON column behave like attributes.

Full credit needs store accessors for `theme` and `digest` on `settings`. `handrolled.rb` passes the behaviour tests with hand-written methods that read and merge the hash, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/Store.html
