# Refuse to delete a category that still has products

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `dependent: :restrict_with_error` so a blocked delete becomes a validation-style error.

Full credit needs `dependent: :restrict_with_error` on `products`. `handrolled.rb` passes the behaviour tests with a `before_destroy` callback that aborts, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/Associations/ClassMethods.html
- https://guides.rubyonrails.org/association_basics.html
