# Expected credit 0.1: hand-built month bounds plus a helper call that never runs.
class Invoice < ActiveRecord::Base
  scope :for_month, ->(date) { where(issued_on: Date.new(date.year, date.month, 1)..Date.new(date.year, date.month, -1)) }
end

if false
  all_month
end
