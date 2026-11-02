# Compute local reporting days across daylight saving changes

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Build each local midnight separately (here with `Date#in_time_zone`) and convert to UTC, without touching the caller's time zone.

No API check: there is no single Rails API to require, so passing the behaviour tests gives full credit.

Written from these public references:

- https://api.rubyonrails.org/classes/ActiveSupport/TimeWithZone.html
- https://api.rubyonrails.org/classes/Time.html
