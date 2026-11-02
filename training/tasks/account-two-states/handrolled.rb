class Account < ActiveRecord::Base
  enum :status, { active: 0, archived: 1 }, prefix: true

  BILLING = { 'active' => 0, 'past_due' => 1 }.freeze

  def billing_state
    BILLING.key(self[:billing_state])
  end

  def billing_state=(value)
    self[:billing_state] = BILLING.fetch(value.to_s)
  end

  def billing_active? = billing_state == 'active'
  def billing_past_due? = billing_state == 'past_due'
end
