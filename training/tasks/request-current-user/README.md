# Hold the current user per request

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Subclass `ActiveSupport::CurrentAttributes` for per-request globals that are isolated and reset.

Full credit needs `Current` inheriting from `ActiveSupport::CurrentAttributes`. `handrolled.rb` passes the behaviour tests with hand-written `Thread.current` accessors, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveSupport/CurrentAttributes.html
