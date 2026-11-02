# A class setting that subclasses can override

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `class_attribute` so each subclass can override a setting without affecting its parent or siblings.

Full credit needs a call to `class_attribute`. `handrolled.rb` passes the behaviour tests with class-level instance variables with a superclass lookup, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/Class.html
