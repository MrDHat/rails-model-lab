# Reach tags through a join model

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Declare `has_many :through` so tags are a real association you can query and join.

Full credit needs `has_many :tags, through: :taggings`. `handrolled.rb` passes the behaviour tests with a method that builds the query by hand, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/Associations/ClassMethods.html
- https://guides.rubyonrails.org/association_basics.html
