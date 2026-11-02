class Reservation < ActiveRecord::Base
  validates :pickup_on, :return_on, presence: true
  validates :return_on, comparison: { greater_than: :pickup_on }, if: :pickup_on
end
