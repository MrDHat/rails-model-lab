The nightly overdue sweep (`OverdueSweepJob`) sends one email per overdue
loan, so a member with three overdue tools gets three emails. Send each
member who has overdue loans a single email instead,
`LoanMailer.overdue_summary(member)`, with the subject "3 tools overdue" (or
"1 tool overdue") and a line per overdue tool giving its name and due date,
like "Cordless drill, due May 01, 2026". Keep `LoanMailer.overdue` as it is.

The sweep now enqueues tens of thousands of emails a night and the queue's
round trips are the slow part, so the sweep should hand the emails to the
queue in bulk instead of enqueuing each one on its own.
