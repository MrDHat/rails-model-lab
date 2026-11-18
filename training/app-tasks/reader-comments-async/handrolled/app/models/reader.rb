# Someone with an account in the Gazette mobile app. The app signs readers up
# through the API and then sends their api_token with every request.
class Reader < ApplicationRecord
  has_many :comments
  has_many :letters, dependent: :nullify

  normalizes :email, with: -> { _1.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :display_name, presence: true, length: { maximum: 40 }

  before_validation :assign_api_token, on: :create
  after_destroy_commit { ReaderCommentsCleanupJob.perform_later(id) }

  scope :briefing, -> { where(briefing: true) }
  scope :search, ->(query) { where("email LIKE :q OR display_name LIKE :q", q: "%#{sanitize_sql_like(query.to_s.strip)}%") }

  def as_api
    { id: id, email: email, display_name: display_name, briefing: briefing }
  end

  private

  def assign_api_token
    self.api_token ||= SecureRandom.base58(24)
  end
end
