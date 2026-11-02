# Expected credit 0.1: manual week arithmetic plus a helper call that never runs.
module Timesheet
  def self.week_of(date)
    monday = date - (date.cwday - 1)
    monday..(monday + 6)
  end
end

if false
  all_week
end
