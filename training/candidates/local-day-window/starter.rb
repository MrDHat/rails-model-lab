class DailyWindow
  def self.for(date:, zone:)
    Time.use_zone(zone) do
      start_at = Time.zone.local(date.year, date.month, date.day).utc
      start_at...(start_at + 86_400)
    end
  end
end
