require 'active_record'
require 'active_support/all'
require 'minitest/autorun'
require 'bigdecimal'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false

implementation = ENV.fetch('CANDIDATE_IMPLEMENTATION', 'reference.rb')
require File.expand_path(implementation, __dir__)

class LocalDayWindowTest < Minitest::Test
  def window(date)
    DailyWindow.for(date: date, zone: 'Europe/Dublin')
  end

  def test_spring_day_has_23_hours
    range = window(Date.new(2026, 3, 29))
    assert_equal Time.utc(2026, 3, 29), range.begin
    assert_equal Time.utc(2026, 3, 29, 23), range.end
    assert_equal 23 * 3600, range.end - range.begin
  end

  def test_autumn_day_has_25_hours
    range = window(Date.new(2026, 10, 25))
    assert_equal Time.utc(2026, 10, 24, 23), range.begin
    assert_equal Time.utc(2026, 10, 26), range.end
    assert_equal 25 * 3600, range.end - range.begin
  end

  def test_summer_boundaries_cross_utc_dates
    range = window(Date.new(2026, 7, 15))
    assert_equal Time.utc(2026, 7, 14, 23), range.begin
    assert_equal Time.utc(2026, 7, 15, 23), range.end
    assert range.begin.utc?
    assert range.end.utc?
    assert_instance_of Time, range.begin
    assert_instance_of Time, range.end
    assert range.exclude_end?
    assert range.cover?(range.begin)
    refute range.cover?(range.end)
  end

  def test_ordinary_winter_day_has_24_hours
    range = window(Date.new(2026, 1, 15))
    assert_equal 24 * 3600, range.end - range.begin
  end

  def test_restores_callers_zone_and_environment
    old_env = ENV.to_h.slice('TZ')
    Time.use_zone('Asia/Tokyo') do
      before = Time.zone
      window(Date.new(2026, 3, 29))
      assert_same before, Time.zone
    end
    assert_equal old_env, ENV.to_h.slice('TZ')
  end

  def test_unknown_zone_raises_and_restores_callers_zone
    Time.use_zone('Asia/Tokyo') do
      before = Time.zone
      assert_raises(ArgumentError) do
        DailyWindow.for(date: Date.new(2026, 1, 1), zone: 'Missing/Zone')
      end
      assert_same before, Time.zone
    end
  end
end
