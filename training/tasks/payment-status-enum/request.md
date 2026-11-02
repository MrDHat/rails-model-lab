Payment.status uses existing integer codes: pending=0, settled=10, failed=20.
Keep those database values unchanged. Expose status_pending?, status_settled?
and status_failed? predicates, and make a new payment pending by default.
Unknown strings and explicit nil from a form must be assignable without an
exception, then fail ordinary model validation. Persisted status code 10 must
still read as settled. Do not change the supplied database schema.
