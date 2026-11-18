The staff day schedule (`/staff/schedule`) takes seconds on busy days at
Paulista: it runs several database queries for every appointment on the
page. Make the page load the day's appointments together with everything it
shows for them (patient, practitioner, treatment, room, clinical note,
invoice), so the number of queries stays the same however many appointments
the day has. The page shows exactly what it shows now.
