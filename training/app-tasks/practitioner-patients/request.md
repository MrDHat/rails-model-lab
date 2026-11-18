Practitioners want to see who they've treated. Add `practitioner.patients`:
the patients the practitioner has seen, meaning patients with at least one
completed appointment with them, each patient once. It must be a relation
the upcoming reports can keep filtering and ordering (for example
`practitioner.patients.where(locale: "pt-BR").order(:name)`).

On the practitioner's staff page, add a "Patients seen" section after
"Upcoming", listing them by name in a `ul.patients-seen`, each linking to the
patient's page.
