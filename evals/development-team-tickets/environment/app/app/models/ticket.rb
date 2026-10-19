class Ticket < ApplicationRecord
  belongs_to :team
  validates :title, presence: true
  validates :status, inclusion: { in: %w[open closed] }
end
