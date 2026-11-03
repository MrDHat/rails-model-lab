module Billing
  def self.next_date(date)
    Date.new(date.year, date.month % 12 + 1, date.day)
  rescue Date::Error
    Date.new(date.year, date.month % 12 + 1, 28)
  end
end
