class Reservation < ActiveRecord::Base
  validates :pickup_on, :return_on, presence: true
end
