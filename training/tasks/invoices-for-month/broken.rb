class Invoice < ActiveRecord::Base
  scope :for_month, ->(date) { where(issued_on: Date.new(date.year, date.month, 1)..(Date.new(date.year, date.month, 1) + 30)) }
end
