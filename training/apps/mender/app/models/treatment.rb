class Treatment < ApplicationRecord
  has_many :practitioner_treatments, dependent: :destroy
  has_many :practitioners, through: :practitioner_treatments
  has_many :appointments, dependent: :restrict_with_exception

  scope :active, -> { where(active: true) }

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true, format: { with: /\A[A-Z]{2,6}\z/ }
  validates :duration_minutes, numericality: { only_integer: true, greater_than: 0 }
  validates :price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def as_api = { code: code, name: name, duration_minutes: duration_minutes, price_cents: price_cents }
end
