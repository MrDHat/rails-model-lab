class Tool < ApplicationRecord
  validate :name_unique_in_category

  def name_unique_in_category
    clash = Tool.where(category_id: category_id).where("LOWER(name) = ?", name.to_s.downcase).where.not(id: id)
    errors.add(:name, "is already used in this category") if clash.exists?
  end

  belongs_to :category
  has_many :loans

  validates :name, :serial, presence: true
  validates :serial, uniqueness: true
  validates :daily_fee_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :in_service, -> { where(retired_at: nil) }

  def on_loan? = loans.open.exists?
end
