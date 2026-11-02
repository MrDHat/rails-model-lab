class DailyWindow
  def self.for(date:, zone:)
    date.in_time_zone(zone).utc...(date + 1).in_time_zone(zone).utc
  end
end
