# Bump the parent's timestamp when a child changes

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `touch: true` on the belongs_to so changes to a task update the project's `updated_at`.

Full credit needs `touch: true` on the task's `project` association. `handrolled.rb` passes the behaviour tests with callbacks that call `touch`, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/Associations/ClassMethods.html
