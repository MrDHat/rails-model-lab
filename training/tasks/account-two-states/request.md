Account fails to load because status and billing_state both have a value
called active. Keep the integer codes (status: active 0, archived 1;
billing_state: active 0, past_due 1). account.status and
account.billing_state must return names such as "archived" and "past_due",
and callers must be able to write
Account.create!(status: :archived, billing_state: :past_due) and
Account.where(billing_state: :past_due).
