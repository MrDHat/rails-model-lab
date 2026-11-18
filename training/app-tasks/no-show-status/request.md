Reception wants to record patients who don't turn up. Add a "no show"
status for appointments, stored as 4 in `appointments.status` (0 to 3 keep
their meaning).

- On the staff appointment page, a booked appointment whose start time has
  passed gets a "Mark no-show" button, which sends
  `PATCH /staff/appointments/:id` with `event=no_show`. Any other appointment
  (one still to start, checked in, completed or cancelled) is refused with
  the alert "only booked appointments that have started can be marked
  no-show".
- The API and the staff pages show the status as `no_show`, and the change
  is audited like the other status changes.
- The monthly report gets its own `no_show` line.
- `Appointment.no_show` should give the no-show appointments and
  `appointment.no_show?` whether one is.

A no-show doesn't free the slot: nobody on the waitlist is offered it.
