class Room < ApplicationRecord
  belongs_to :location
  has_many :appointments, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :location_id }

  def free_between?(starts_at, ends_at)
    appointments.active.where("starts_at < ? AND ends_at > ?", ends_at, starts_at).none?
  end
end
