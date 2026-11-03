# Accept a nested belongs_to address

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `accepts_nested_attributes_for` on the belongs_to so the form can create or update the address.

Full credit needs nested attributes declared for `billing_address`. `handrolled.rb` passes the behaviour tests with a hand-written attributes writer with autosave, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/NestedAttributes/ClassMethods.html
