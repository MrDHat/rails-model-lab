Patients whose language is set to Portuguese (`locale` "pt-BR") still get
their appointment reminders, waitlist offers, and booking confirmation and
cancellation emails in English. The Portuguese wording is already in
`config/locales/pt-BR.yml`.

Send each patient's texts and emails in their own language, dates and times
included (a Portuguese reminder reads "... em seg 15 jun, 11:00 ..."). Other
patients, the staff pages and the API stay in English, including whatever a
job or mailer does after a Portuguese message.
