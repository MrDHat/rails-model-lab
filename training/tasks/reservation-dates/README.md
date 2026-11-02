# Validate reservation dates on creation and update

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use the comparison validator so ordering is checked on every save. The update case rejects a create-only fix.

Full credit needs a comparison validator on `return_on`. `handrolled.rb` passes the behaviour tests with a custom validation method, so it gets 0.1.

Written from these public references:

- https://guides.rubyonrails.org/active_record_validations.html
