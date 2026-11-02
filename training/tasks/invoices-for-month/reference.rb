class Invoice < ActiveRecord::Base
  scope :for_month, ->(date) { where(issued_on: date.all_month) }
end
