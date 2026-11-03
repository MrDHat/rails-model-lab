class Account < ActiveRecord::Base
  enum :status, { active: 0, archived: 1 }, prefix: true

  class BillingType < ActiveModel::Type::Value
    CODES = { 'active' => 0, 'past_due' => 1 }.freeze

    def cast(value) = value.nil? ? nil : (CODES.key(value) || value.to_s)
    def serialize(value) = CODES[cast(value)]
    def deserialize(value) = CODES.key(value)
  end

  attribute :billing_state, BillingType.new
end
