# Record jobs that give up

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `after_discard` to act once a job is finally given up, alongside `retry_on`.

Full credit needs an `after_discard` callback. `handrolled.rb` passes the behaviour tests with a block on `retry_on`, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveJob/Exceptions/ClassMethods.html
