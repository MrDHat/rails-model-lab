class Loan < ApplicationRecord
  belongs_to :member
  belongs_to :tool

  validates :due_on, presence: true
  validate :tool_available, on: :create
  validate :member_not_banned, on: :create

  scope :open, -> { where(returned_at: nil) }
  scope :overdue, -> { open.where(due_on: ...Date.current) }

  def overdue? = returned_at.nil? && due_on < Date.current

  def return!(at: Time.current)
    days = [(at.to_date - created_at.to_date).to_i, 1].max
    update!(returned_at: at, fee_cents: days * tool.daily_fee_cents)
  end

  private

  def tool_available
    errors.add(:tool, "is already on loan") if tool&.on_loan?
  end

  def member_not_banned
    errors.add(:member, "is banned") if member&.banned?
  end
end
