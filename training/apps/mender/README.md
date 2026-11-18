# Mender

Bookings, notes and billing for Mender, a chain of physiotherapy clinics in
São Paulo. Patients book and pay through the mobile app, which talks to the
JSON API under /api (each app build has an API client token). Reception,
practitioners and managers use the staff pages under /staff after signing in.
Appointment reminders go out by text message the day before, and invoices
for insured patients are claimed from the insurer by a background job.

Times are shown and days are counted in the clinics' time zone
(America/Sao_Paulo); amounts are in centavos.

    bin/rails db:setup   # schema and seed data
    bin/rails test

## Where things live

- `app/models`: the records, plus `PhoneNumber`, `SmsGateway` and
  `InsurerGateway` (stand-ins for the SMS provider and the insurers' API).
- `app/services`: booking, slot search, invoicing, claims export, the monthly
  report and the waitlist.
- `app/jobs`: reminders, claim submission and waitlist offers.
- `app/controllers/api`: the patient app's API.
- `app/controllers/staff`: the staff pages.
- `app/controllers/bookings_controller.rb`: the page patients reach from the
  link in their confirmation email.
