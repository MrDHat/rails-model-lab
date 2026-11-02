# Share scopes and methods across models

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Write the shared behaviour as an `ActiveSupport::Concern` with `included` and `class_methods`.

Full credit needs `Archivable` extending `ActiveSupport::Concern`. `handrolled.rb` passes the behaviour tests with a plain module with a `self.included` hook, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveSupport/Concern.html
