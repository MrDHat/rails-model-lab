# Someone with an account in the Gazette mobile app. The app signs readers up
# through the API and then sends their api_token with every request.
class Reader < ApplicationRecord
  has_many :comments, dependent: :destroy
  has_many :letters, dependent: :nullify

  has_secure_token :api_token

  normalizes :email, with: -> { _1.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :display_name, presence: true, length: { maximum: 40 }

  scope :briefing, -> { where(briefing: true) }
  scope :search, ->(query) { where("email LIKE :q OR display_name LIKE :q", q: "%#{sanitize_sql_like(query.to_s.strip)}%") }

  def as_api
    { id: id, email: email, display_name: display_name, briefing: briefing }
  end
end
