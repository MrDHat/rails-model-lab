# Keep a comment count column accurate

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use a counter cache on the belongs_to so the count is kept up to date for you.

Full credit needs `counter_cache` on the comment's `post` association. `handrolled.rb` passes the behaviour tests with callbacks that recount after create and destroy, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/Associations/ClassMethods.html
