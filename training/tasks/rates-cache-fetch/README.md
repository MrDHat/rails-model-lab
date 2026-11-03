# Cache a slow lookup for ten minutes

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `cache.fetch` with `expires_in`, which reads, computes on a miss and writes in one call.

Full credit needs a call to `fetch` on the cache. `handrolled.rb` passes the behaviour tests with separate `read` and `write` calls, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveSupport/Cache/Store.html
- https://guides.rubyonrails.org/caching_with_rails.html
