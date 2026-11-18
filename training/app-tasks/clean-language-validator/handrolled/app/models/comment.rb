# Reader comments arrive through the app and wait for a moderator.
class Comment < ApplicationRecord
  include CleanLanguage

  belongs_to :article, counter_cache: true, touch: true
  belongs_to :reader

  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :body, presence: true, length: { maximum: 2000 }
  checks_language_of :body
  validate :article_open_for_comments, on: :create

  after_create_commit :alert_authors

  scope :oldest_first, -> { order(:created_at, :id) }

  def as_api
    { id: id, body: body, reader: reader.display_name, status: status, created_at: created_at.iso8601 }
  end

  private

  def article_open_for_comments
    errors.add(:base, "Comments are closed on this story.") unless article&.live? && article.comments_open?
  end

  def alert_authors
    CommentAlertJob.perform_later(self)
  end
end
