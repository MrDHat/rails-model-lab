The link in the booking confirmation email goes to `/bookings/<appointment
id>`, so anyone who tries other numbers can see other patients' bookings and
cancel them. Make the link carry a token instead of the id:

- The confirmation email links to `/bookings/<token>`; that page and
  cancelling from it (`DELETE /bookings/<token>`) work as before. After
  cancelling, the page shows "Your appointment has been cancelled."
- Anything that isn't a valid token, including a bare appointment id, is a
  404.
- A link stops working once the appointment is cancelled or moved to
  another time (a moved appointment's new confirmation email has a fresh
  link), and 30 days after it was sent in any case.
