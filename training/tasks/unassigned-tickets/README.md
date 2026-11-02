# Find records with no associated row

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `where.missing` to find rows whose association is absent, including dangling foreign keys.

Full credit needs a call to `missing`. `handrolled.rb` passes the behaviour tests with a hand-written left join with an IS NULL condition, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/QueryMethods/WhereChain.html
