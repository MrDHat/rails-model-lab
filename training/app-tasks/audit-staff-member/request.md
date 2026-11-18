Audit events say what changed but never who: `audit_events.staff_user_id`
is always empty. Events are recorded from several models and jobs (status
changes, voided invoices, rejected claims) and more are coming, so rather
than handing the user to each of them, make any event recorded while a
staff page request is handled carry the signed-in staff member.

Events recorded outside a staff request (API calls from the patient app,
background jobs) keep no staff member, even when they run right after a
staff request.
