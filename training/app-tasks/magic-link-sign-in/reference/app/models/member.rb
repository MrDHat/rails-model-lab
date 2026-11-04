class Member < ApplicationRecord
  has_many :loans

  generates_token_for :sign_in, expires_in: 15.minutes do
    link_signed_in_at
  end

  def self.find_by_sign_in_token(token) = find_by_token_for(:sign_in, token)

  def sign_in_token = generate_token_for(:sign_in)

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  def banned? = banned_at.present?

  def ban!
    update!(banned_at: Time.current)
  end
end
