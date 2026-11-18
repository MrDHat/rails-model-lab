class Correction < ApplicationRecord
  belongs_to :article, touch: true
  belongs_to :editor

  validates :body, presence: true
end
