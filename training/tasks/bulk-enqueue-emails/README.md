# Enqueue many jobs in one call

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `ActiveJob.perform_all_later` so the queue adapter can enqueue a batch at once.

Full credit needs a call to `perform_all_later`. `handrolled.rb` passes the behaviour tests by handing the jobs straight to the queue adapter's `enqueue_all`, so it gets 0.1. One `perform_later` per user fails the behaviour tests.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveJob.html
- https://guides.rubyonrails.org/active_job_basics.html
