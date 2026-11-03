class Member < ApplicationRecord
  has_many :loans

  def self.sign_in_verifier = Rails.application.message_verifier(:sign_in)

  def self.find_by_sign_in_token(token)
    id, signed_in_at = sign_in_verifier.verified(token)
    member = find_by(id: id)
    member if member && member.link_signed_in_at&.iso8601(6) == signed_in_at
  rescue ArgumentError
    nil
  end

  def sign_in_token = self.class.sign_in_verifier.generate([id, link_signed_in_at&.iso8601(6)], expires_in: 15.minutes)

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  def banned? = banned_at.present?

  def ban!
    update!(banned_at: Time.current)
  end
end
