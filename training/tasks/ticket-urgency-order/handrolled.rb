class Issue < ActiveRecord::Base
  enum :priority, { normal: 0, low: 1, urgent: 2, high: 3 }

  scope :by_urgency, -> {
    order(Arel.sql('CASE priority WHEN 2 THEN 0 WHEN 3 THEN 1 WHEN 0 THEN 2 ELSE 3 END'), :id)
  }
end
