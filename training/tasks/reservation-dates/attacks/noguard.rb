# Expected credit 1.0: comparison without an if guard, still correct.
class Reservation < ActiveRecord::Base
  validates :pickup_on, :return_on, presence: true
  validates :return_on, comparison: { greater_than: :pickup_on }
end
