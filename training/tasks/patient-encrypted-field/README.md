# Encrypt a sensitive column

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Declare `encrypts` so Active Record encrypts the value at rest and decrypts on read.

Full credit needs `tax_id` declared with `encrypts`. `handrolled.rb` passes the behaviour tests with a custom attribute type built on MessageEncryptor, so it gets 0.1.

Written from these public references:

- https://guides.rubyonrails.org/active_record_encryption.html
