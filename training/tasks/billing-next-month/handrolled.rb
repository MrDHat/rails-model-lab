module Billing
  def self.next_date(date)
    year, month = date.month == 12 ? [date.year + 1, 1] : [date.year, date.month + 1]
    last_day = Date.new(year, month, -1).day
    Date.new(year, month, [date.day, last_day].min)
  end
end
