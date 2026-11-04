class Member < ApplicationRecord
  has_many :loans
  has_many :borrowed_tools, -> { distinct }, through: :loans, source: :tool

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  def banned? = banned_at.present?

  def ban!
    update!(banned_at: Time.current)
  end
end
