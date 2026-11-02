# List books with authors without N+1 queries

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Preload the association with `includes` (or `preload`/`eager_load`) instead of querying per row.

Full credit needs a call to `includes`, `preload` or `eager_load`, or `joins` with `pluck` in one query. `handrolled.rb` passes the behaviour tests with loading authors by id and matching them up by hand, so it gets 0.1.

Written from these public references:

- https://guides.rubyonrails.org/active_record_querying.html
