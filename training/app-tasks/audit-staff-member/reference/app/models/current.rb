# Per-request context, reset after every request and job.
class Current < ActiveSupport::CurrentAttributes
  attribute :staff_user
end
