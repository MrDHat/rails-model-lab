class Insurer < ApplicationRecord
  has_many :insurance_policies, dependent: :restrict_with_exception
  has_many :insurance_claims, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
