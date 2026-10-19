class ExpenseClaim < ApplicationRecord
  validates :status, inclusion: { in: %w[draft submitted] }
end
