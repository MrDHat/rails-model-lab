class Location < ApplicationRecord
  has_many :rooms, dependent: :destroy
  has_many :practitioners, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
  validates :address, presence: true

  def appointments = Appointment.where(practitioner: practitioners)
end
