module Timesheet
  def self.week_of(date)
    date..(date + 6)
  end
end
