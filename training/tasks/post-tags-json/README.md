# Store a list of tags as JSON text

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Serialize the attribute with a JSON coder and an Array type so it reads as a list and defaults to empty.

Full credit needs `tags` serialized (Active Record's serialized attribute type). `handrolled.rb` passes the behaviour tests with hand-written JSON parse and generate methods, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/AttributeMethods/Serialization/ClassMethods.html
