# Cap how many nested rows one form can submit

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use the `limit` option on nested attributes rather than counting rows by hand.

Full credit needs a nested-attributes limit of 5 on `questions`. `handrolled.rb` passes the behaviour tests with an overridden attributes writer that counts rows, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/NestedAttributes/ClassMethods.html
