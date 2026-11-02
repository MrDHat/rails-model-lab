# Select records from one calendar month

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Query with the date's `all_month` range instead of building month boundaries by hand.

Full credit needs `all_month` (or `beginning_of_month`/`end_of_month`). `handrolled.rb` passes the behaviour tests with hand-built first and last dates, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/DateAndTime/Calculations.html
- https://guides.rubyonrails.org/active_record_querying.html
