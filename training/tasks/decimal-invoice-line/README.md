# Keep invoice subtotals in decimal arithmetic

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Validate the numeric input and multiply before rounding, so line totals don't pick up per-unit rounding errors.

Full credit needs a numericality or comparison lower bound on unit_price, and a numericality validator with `only_integer` on quantity. `handrolled.rb` passes the behaviour tests with a custom validation method, so it gets 0.1.

Written from these public references:

- https://guides.rubyonrails.org/active_record_validations.html
- https://api.rubyonrails.org/v8.0.1/classes/ActiveRecord/Type.html
- https://docs.ruby-lang.org/en/3.3/BigDecimal.html
