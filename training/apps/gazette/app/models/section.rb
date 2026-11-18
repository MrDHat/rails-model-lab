class Section < ApplicationRecord
  has_many :articles, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 40 }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }

  def to_param = slug

  def latest(limit = 5) = articles.live.newest_first.limit(limit)
end
