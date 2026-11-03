require 'minitest/autorun'
require_relative 'setup'

class InvoiceMonthTest < Minitest::Test
  def test_february
    Invoice.delete_all
    %w[2026-01-31 2026-02-01 2026-02-28 2026-03-01 2026-03-02].each { Invoice.create!(issued_on: _1) }
    dates = Invoice.for_month(Date.new(2026, 2, 14)).order(:issued_on).pluck(:issued_on).map(&:to_s)
    assert_equal %w[2026-02-01 2026-02-28], dates
  end

  def test_long_month_includes_the_31st
    Invoice.delete_all
    Invoice.create!(issued_on: '2026-03-31')
    assert_equal 1, Invoice.for_month(Date.new(2026, 3, 1)).count
  end
end
