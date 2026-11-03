class Account < ActiveRecord::Base
  enum :status, { active: 0, archived: 1 }
  enum :billing_state, { billing_active: 0, past_due: 1 }
end
