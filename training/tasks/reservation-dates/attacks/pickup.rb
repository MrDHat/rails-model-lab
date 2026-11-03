# Expected credit 0.0: puts the error on pickup_on, not return_on.
class Reservation < ActiveRecord::Base
  validates :pickup_on, :return_on, presence: true
  validates :pickup_on, comparison: { less_than: :return_on }, if: :return_on
end
