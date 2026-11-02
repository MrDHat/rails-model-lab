require 'minitest/autorun'
require_relative 'setup'

class BillingDateTest < Minitest::Test
  def test_same_day_next_month
    assert_equal Date.new(2026, 4, 15), Billing.next_date(Date.new(2026, 3, 15))
  end

  def test_clamps_to_month_end
    assert_equal Date.new(2026, 2, 28), Billing.next_date(Date.new(2026, 1, 31))
    assert_equal Date.new(2028, 2, 29), Billing.next_date(Date.new(2028, 1, 31))
    assert_equal Date.new(2026, 4, 30), Billing.next_date(Date.new(2026, 3, 31))
  end

  def test_rolls_over_the_year
    assert_equal Date.new(2027, 1, 31), Billing.next_date(Date.new(2026, 12, 31))
  end
end
