class Member < ApplicationRecord
  has_many :loans

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  def banned? = banned_at.present?

  # Undoes what it already did if a return fails.
  def ban!
    returned = []
    update!(banned_at: Time.current)
    loans.open.each do |loan|
      loan.return!(at: banned_at)
      returned << loan
    end
  rescue StandardError
    returned.each { _1.update!(returned_at: nil, fee_cents: nil) }
    update!(banned_at: nil)
    raise
  end
end
