# Reader comments arrive through the app and wait for a moderator.
class Comment < ApplicationRecord
  BANNED_WORDS = %w[scam idiot moron crook].freeze

  belongs_to :article, counter_cache: true, touch: true
  belongs_to :reader

  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :body, presence: true, length: { maximum: 2000 }
  validate :no_banned_words
  validate :article_open_for_comments, on: :create

  after_create_commit :alert_authors

  scope :oldest_first, -> { order(:created_at, :id) }

  def as_api
    { id: id, body: body, reader: reader.display_name, status: status, created_at: created_at.iso8601 }
  end

  private

  def no_banned_words
    words = body.to_s.split(/\W+/)
    errors.add(:body, "contains words we don't publish") if words.intersect?(BANNED_WORDS)
  end

  def article_open_for_comments
    errors.add(:base, "Comments are closed on this story.") unless article&.live? && article.comments_open?
  end

  def alert_authors
    CommentAlertJob.perform_later(id)
  end
end
