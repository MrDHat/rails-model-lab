# Require accepting the terms at signup

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use the acceptance validator, which also gives a virtual attribute, and require it only on create.

Full credit needs an acceptance validator on `terms_of_service`. `handrolled.rb` passes the behaviour tests with an attribute accessor and a custom validation, so it gets 0.1.

Written from these public references:

- https://guides.rubyonrails.org/active_record_validations.html
