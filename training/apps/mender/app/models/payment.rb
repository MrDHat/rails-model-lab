class Payment < ApplicationRecord
  METHODS = %w[card pix cash].freeze

  belongs_to :invoice

  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :method, inclusion: { in: METHODS }
  validates :received_at, presence: true
end
