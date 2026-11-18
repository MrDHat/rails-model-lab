class InsurancePolicy < ApplicationRecord
  belongs_to :patient
  belongs_to :insurer

  validates :member_number, presence: true
  validates :coverage_percent, numericality: { only_integer: true, in: 0..100 }
  validates :valid_until, presence: true

  def valid_on?(date) = valid_until >= date
end
