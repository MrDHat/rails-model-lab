Account fails to load because status and billing_state both have a value
called active. Keep the integer codes (status: active 0, archived 1;
billing_state: active 0, past_due 1). Callers need status_active?,
status_archived?, billing_active? and billing_past_due?, and must be able to
write Account.create!(status: :archived, billing_state: :past_due).
