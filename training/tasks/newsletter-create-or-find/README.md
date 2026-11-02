# Subscribe an email without duplicate errors

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `create_or_find_by!`, which inserts first and falls back to the existing row on a unique-index conflict.

Full credit needs a call to `create_or_find_by`, or to `find_or_create_by`, which falls back to it since Rails 8.0 (either with or without `!`). `handrolled.rb` passes the behaviour tests with `find_by` followed by `create!`, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/Relation.html
