# Normalize contact email assignment and lookup

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Declare normalization on the attribute so assignment and hash lookup use the same rule.

Full credit needs `normalizes :email` is declared. `handrolled.rb` passes the behaviour tests with a custom attribute type that normalizes on cast, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v7.2.4/classes/ActiveRecord/Normalization.html
- https://api.rubyonrails.org/v8.1.3/classes/ActiveModel/Attributes/Normalization.html
