Patients miss appointments that were moved without them noticing. Whenever
an appointment's start time changes, whether the patient moved it in the
app, reception moved it on the staff page, or anything else changed it,
text the patient:

    Hi Julia, your appointment with Ana Souza has moved to Wed 17 Jun, 09:00 at Mender Paulista.

(the time in clinic time, in the same format as the reminder texts).

- Send it from a new background job, `AppointmentMovedJob`, taking the
  appointment, so a slow SMS provider doesn't hold up the request.
- Only when the start time actually changed: not for other edits, status
  changes or new bookings.
- Only once the change is saved for good: if the save is rolled back, no
  job and no text.
