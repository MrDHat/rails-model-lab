# Letters to the editor, sent from the form on the website. The letters desk
# replies to the writer straight from the notification email.
class Letter < ApplicationRecord
  belongs_to :reader, optional: true

  enum :status, { received: 0, accepted: 1, declined: 2 }

  normalizes :email, with: -> { _1.strip.downcase }

  validates :name, :email, :subject, :body, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, length: { maximum: 120 }
  validates :body, length: { maximum: 3000 }
  validates :subject, :body, clean_language: true

  after_create_commit :notify_desk

  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  def signature = [name, town].compact_blank.join(", ")

  private

  def notify_desk
    LetterMailer.received(self).deliver_later
    LetterMailer.acknowledgement(self).deliver_later
  end
end
