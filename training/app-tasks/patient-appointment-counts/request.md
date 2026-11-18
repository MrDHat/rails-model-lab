Reception wants to see how many appointments each patient has had, to spot
regulars. On the staff patients list (`/staff/patients`), add an
"Appointments" column with each patient's number of appointments (all of
them, whatever their status), and let reception sort the list by it, most
first and then by name, with `/staff/patients?sort=appointments`. Searching
and paging work with the sort too.

There are tens of thousands of patients, so the page must not count
appointments patient by patient: keep each patient's number in a new
`patients.appointments_count` column, kept right as appointments are created
and deleted, and filled in for existing patients when the column is added.
