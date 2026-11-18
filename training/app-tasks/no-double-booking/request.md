Ana had two patients turn up for her 09:00 last Monday: one booked in the
app while reception booked the other by phone, and both went through. A
practitioner can't have two appointments starting at the same time.

Refuse the second one with "Starts at is already booked for this
practitioner": the API answers 422 with that in `errors`, and reception's
booking form shows it. Moving an appointment onto a start time that's taken
is refused the same way. Cancelled appointments don't count, so a cancelled
slot can be booked again, and other practitioners are free to start at the
same time.
