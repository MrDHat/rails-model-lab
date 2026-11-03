# Expected credit 1.0: start of day plus one day, still correct.
class DailyWindow
  def self.for(date:, zone:)
    start = date.in_time_zone(zone)
    start.utc...(start + 1.day).utc
  end
end
