Practitioners want time after each appointment to write their notes. Give
each practitioner a buffer, in whole minutes from 0 to 60 (0 unless set),
kept in the practitioners' existing `settings` JSON column under
`"buffer_minutes"`.

- Managers set it on the practitioner's edit page, as
  `practitioner[buffer_minutes]`. Anything outside 0 to 60, or not a whole
  number, is refused with "Buffer minutes must be in 0..60".
- The slot search keeps that many minutes free after each of the
  practitioner's appointments, and makes new appointments end at least that
  long before the next one starts. Cancelled appointments still don't count.
- The API's practitioner JSON includes `buffer_minutes`, as a number.
