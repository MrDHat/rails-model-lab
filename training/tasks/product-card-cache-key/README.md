# Build a cache key that changes with the record

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use the record's `cache_key_with_version` so the key changes whenever the record is updated.

Full credit needs `cache_key_with_version` (or `cache_key` plus `cache_version`). `handrolled.rb` passes the behaviour tests with a key built from the id and timestamp, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/Integration.html
- https://guides.rubyonrails.org/caching_with_rails.html
