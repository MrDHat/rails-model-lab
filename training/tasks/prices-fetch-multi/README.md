# Read many cache entries in one round trip

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `fetch_multi`, which reads all keys at once and computes only the misses.

Full credit needs a call to `fetch_multi`. `handrolled.rb` passes the behaviour tests with `read_multi` followed by `write_multi`, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveSupport/Cache/Store.html
