Reception phones patients who signed up in the app but never booked
anything, to help them get started. Add a filter to the staff patients list:
`/staff/patients?filter=never_booked` lists the active patients who have no
appointments at all, sorted by name and searchable with `q` like the full
list. A patient whose only appointments were cancelled did book, so they
aren't on it. Add a "Never booked" link above the list that opens it.
