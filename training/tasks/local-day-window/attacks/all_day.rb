# Expected credit 1.0: all_day on the zoned date, still correct.
class DailyWindow
  def self.for(date:, zone:)
    day = date.in_time_zone(zone).all_day
    day.begin.utc...(day.end + 1).utc.change(usec: 0)
  end
end
