class Tool < ApplicationRecord
  belongs_to :category
  has_many :loans

  validates :name, :serial, presence: true
  validates :serial, uniqueness: true
  validates :daily_fee_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :in_service, -> { where(retired_at: nil) }

  def on_loan? = loans.open.exists?
end
