module Billing
  def self.next_date(date)
    date.next_month
  end
end
