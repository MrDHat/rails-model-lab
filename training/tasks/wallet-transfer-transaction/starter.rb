class Wallet < ActiveRecord::Base
  validate { errors.add(:base, 'frozen') if frozen_account? && cents_changed? }
end

module Transfer
  def self.call(from, to, cents)
    from.update!(cents: from.cents - cents)
    to.update!(cents: to.cents + cents)
  end
end
