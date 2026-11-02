# Drop a job whose record is gone

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `discard_on` so a job for a deleted record is dropped quietly instead of failing or retrying.

Full credit needs `discard_on ActiveRecord::RecordNotFound`. `handrolled.rb` passes the behaviour tests with a rescue inside `perform` (a `rescue_from` with an empty handler scores the same), so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveJob/Exceptions/ClassMethods.html
