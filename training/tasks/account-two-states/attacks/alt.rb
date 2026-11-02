# Expected credit 0.0: enums with the wrong stored codes.
class Account < ActiveRecord::Base
  enum :status, { active: 9, archived: 1 }, prefix: true
  enum :billing_state, { active: 9, past_due: 1 }, prefix: :billing
end
