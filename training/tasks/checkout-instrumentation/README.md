# Publish an instrumentation event for checkouts

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Wrap the work in `ActiveSupport::Notifications.instrument`, which times it and records errors for subscribers.

Full credit needs a call to `instrument`. `handrolled.rb` passes the behaviour tests with manual timing and `publish`, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveSupport/Notifications.html
- https://guides.rubyonrails.org/active_support_instrumentation.html
