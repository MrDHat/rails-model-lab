# Keep project slugs unique within an account

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use the uniqueness validator with a scope and case-insensitive matching instead of querying by hand.

Full credit needs a uniqueness validator on `slug` scoped to `account_id` and ignoring case. `handrolled.rb` passes the behaviour tests with a custom validation that queries for duplicates, so it gets 0.1.

Written from these public references:

- https://guides.rubyonrails.org/active_record_validations.html
