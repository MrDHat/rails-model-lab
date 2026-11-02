class DailyWindow
  def self.for(date:, zone:)
    Time.zone = zone
    start_at = Time.zone.local(date.year, date.month, date.day)
    tomorrow = date + 1
    end_at = Time.zone.local(tomorrow.year, tomorrow.month, tomorrow.day)
    start_at.utc...end_at.utc
  end
end
