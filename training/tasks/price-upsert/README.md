# Import prices in one statement

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `upsert_all` with `unique_by` to insert new rows and update existing ones in a single query.

Full credit needs a call to `upsert_all`. `handrolled.rb` passes the behaviour tests with raw SQL with ON CONFLICT, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/Persistence/ClassMethods.html
