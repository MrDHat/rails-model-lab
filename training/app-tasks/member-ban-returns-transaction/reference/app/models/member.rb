class Member < ApplicationRecord
  has_many :loans

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  def banned? = banned_at.present?

  def ban!
    transaction do
      update!(banned_at: Time.current)
      loans.open.each { _1.return!(at: banned_at) }
    end
  end
end
