require 'minitest/autorun'
require_relative 'setup'

class WeekRangeTest < Minitest::Test
  def test_midweek
    assert_equal Date.new(2026, 11, 2)..Date.new(2026, 11, 8), Timesheet.week_of(Date.new(2026, 11, 4))
  end

  def test_sunday_belongs_to_the_week_before
    assert_equal Date.new(2026, 11, 2)..Date.new(2026, 11, 8), Timesheet.week_of(Date.new(2026, 11, 8))
  end

  def test_monday_starts_its_own_week
    assert_equal Date.new(2026, 11, 9), Timesheet.week_of(Date.new(2026, 11, 9)).begin
  end

  def test_ignores_app_week_start
    Date.beginning_of_week = :sunday
    assert_equal Date.new(2026, 11, 2), Timesheet.week_of(Date.new(2026, 11, 4)).begin
  ensure
    Date.beginning_of_week = :monday
  end
end
