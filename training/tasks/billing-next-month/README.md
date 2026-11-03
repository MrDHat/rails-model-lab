# Move a billing date forward one month

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Use Active Support's month arithmetic, which clamps to the end of shorter months.

Full credit needs Active Support month arithmetic (`next_month`, `advance`, `months_since` or `1.month`). `handrolled.rb` passes the behaviour tests with hand-built dates using the days in the month, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/DateAndTime/Calculations.html
- https://api.rubyonrails.org/v8.1.3/classes/Date.html
