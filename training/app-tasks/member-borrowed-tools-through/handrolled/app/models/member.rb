class Member < ApplicationRecord
  has_many :loans

  def borrowed_tools = Tool.where(id: loans.select(:tool_id))

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  def banned? = banned_at.present?

  def ban!
    update!(banned_at: Time.current)
  end
end
