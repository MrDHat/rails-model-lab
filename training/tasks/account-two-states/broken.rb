class Account < ActiveRecord::Base
  enum :status, { active: 0, archived: 1 }, prefix: true
  enum :billing_state, { active: 0, past_due: 1 }, suffix: true
end
