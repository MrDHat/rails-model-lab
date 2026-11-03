class Issue < ActiveRecord::Base
  enum :priority, { normal: 0, low: 1, urgent: 2, high: 3 }

  scope :by_urgency, -> { in_order_of(:priority, %w[urgent high normal low]).order(:id) }
end
