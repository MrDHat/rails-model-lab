class Wallet < ActiveRecord::Base
  validate { errors.add(:base, 'frozen') if frozen_account? && cents_changed? }
end

module Transfer
  def self.call(from, to, cents)
    original = from.cents
    from.update!(cents: original - cents)
    begin
      to.update!(cents: to.cents + cents)
    rescue StandardError
      from.update!(cents: original)
      raise
    end
  end
end
