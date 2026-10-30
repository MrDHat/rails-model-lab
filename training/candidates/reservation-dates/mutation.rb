class Reservation < ActiveRecord::Base
  validates :pickup_on, :return_on, presence: true
  validate :return_follows_pickup, on: :create
  def return_follows_pickup
    return unless pickup_on && return_on
    errors.add(:return_on, :invalid) if return_on <= pickup_on
  end
end
