# Move money between wallets atomically

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Wrap both updates in a transaction so a failure part-way rolls everything back.

Full credit needs a call to `transaction`. `handrolled.rb` passes the behaviour tests with a rescue that undoes the first update by hand, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/Transactions/ClassMethods.html
