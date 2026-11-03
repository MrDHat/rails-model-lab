# Retry a job on timeouts only

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `retry_on` with a wait and an attempt limit instead of rescuing and re-enqueuing by hand.

Full credit needs `retry_on` for `Timeout::Error`. `handrolled.rb` passes the behaviour tests with a rescue that calls `retry_job` and counts executions, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveJob/Exceptions/ClassMethods.html
- https://guides.rubyonrails.org/active_job_basics.html
