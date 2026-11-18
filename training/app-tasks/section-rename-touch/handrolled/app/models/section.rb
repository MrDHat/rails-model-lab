class Section < ApplicationRecord
  has_many :articles, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 40 }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }

  # Stories show their section's name, so a new name changes them all.
  after_update -> { articles.update_all(updated_at: Time.current) }, if: :saved_change_to_name?

  def to_param = slug

  def latest(limit = 5) = articles.live.newest_first.limit(limit)
end
