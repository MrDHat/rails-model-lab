class Issue < ActiveRecord::Base
  enum :priority, { normal: 0, low: 1, urgent: 2, high: 3 }
end
