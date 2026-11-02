# Enqueue many jobs in one call

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `ActiveJob.perform_all_later` so the queue adapter can enqueue a batch at once.

Full credit needs a call to `perform_all_later`. `handrolled.rb` passes the behaviour tests with calling `perform_later` in a loop, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveJob.html
- https://guides.rubyonrails.org/active_job_basics.html
