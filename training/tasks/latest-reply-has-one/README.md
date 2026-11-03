# Model the newest reply as an association

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Declare a scoped `has_one` so the newest reply can be preloaded like any association.

Full credit needs a `has_one :latest_reply` association. `handrolled.rb` passes the behaviour tests by preloading every reply and picking the newest in Ruby, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/Associations/ClassMethods.html
