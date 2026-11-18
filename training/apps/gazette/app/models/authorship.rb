class Authorship < ApplicationRecord
  belongs_to :article
  belongs_to :author

  validates :author_id, uniqueness: { scope: :article_id }
end
