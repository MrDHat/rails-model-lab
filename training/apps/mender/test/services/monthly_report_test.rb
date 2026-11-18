require "test_helper"

class MonthlyReportTest < ActiveSupport::TestCase
  setup { @report = MonthlyReport.new(Date.new(2026, 6, 1)) }

  test "counts appointments by status" do
    counts = @report.counts_by_status
    assert_equal [3, 0, 2, 1], counts.values_at("booked", "checked_in", "completed", "cancelled")
    assert_equal 16.7, @report.cancellation_rate
  end

  test "per location" do
    report = MonthlyReport.new(Date.new(2026, 6, 1), location: locations(:pinheiros))
    assert_equal [0, 0, 1, 0], report.counts_by_status.values_at("booked", "checked_in", "completed", "cancelled")
  end

  test "completed by practitioner" do
    assert_equal({ "Ana Souza" => 1, "Carla Mendes" => 1 }, @report.completed_by_practitioner)
  end

  test "money in and out" do
    assert_equal 36000, @report.invoiced_cents
    assert_equal 18000, @report.revenue_cents
  end

  test "an empty month" do
    report = MonthlyReport.new(Date.new(2026, 1, 1))
    assert_equal 0.0, report.cancellation_rate
    assert_equal 0, report.revenue_cents
  end
end
