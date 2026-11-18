# A journalist. Editors sign in to the newsroom; authors are who the bylines
# name, and only some of them are editors too.
class Author < ApplicationRecord
  has_many :authorships, dependent: :restrict_with_error
  has_many :articles, through: :authorships
  has_one :editor, dependent: :nullify

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  def published_articles = articles.live.newest_first
end
