# Expose an associated record's field safely

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use `delegate` with `prefix` and `allow_nil` instead of writing safe-navigation wrappers.

Full credit needs a call to `delegate`. `handrolled.rb` passes the behaviour tests with a hand-written method using safe navigation, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/Module.html
