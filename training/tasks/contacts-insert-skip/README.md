# Bulk insert new rows and keep existing ones

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `insert_all` with `unique_by`, which skips rows that already exist in one statement.

Full credit needs a call to `insert_all`. `handrolled.rb` passes the behaviour tests with raw SQL with ON CONFLICT DO NOTHING, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/Persistence/ClassMethods.html
