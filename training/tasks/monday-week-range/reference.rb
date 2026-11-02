module Timesheet
  def self.week_of(date)
    date.all_week(:monday)
  end
end
