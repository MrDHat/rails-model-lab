module Timesheet
  def self.week_of(date)
    monday = date - (date.cwday - 1)
    monday..(monday + 6)
  end
end
