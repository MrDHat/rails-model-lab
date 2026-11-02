DailyWindow.for(date:, zone:) must return an exclusive-end Range of UTC Time
objects spanning exactly that civil date in the given Rails-recognized time
zone. Reports include the first instant and exclude the next local midnight.
A day can be 23, 24 or 25 hours. Do not assume a fixed 86,400 seconds or mutate
the caller's Time.zone or ENV['TZ']. Unknown zones must raise ArgumentError
without changing the caller's zone. date is a Date; parsing user dates is out
of scope. The implementation must not depend on the current date or time.
