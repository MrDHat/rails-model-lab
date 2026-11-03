module Elapsed
  UNITS = [['day', 86_400], ['hour', 3_600], ['minute', 60], ['second', 1]].freeze

  def self.describe(seconds)
    return '0 seconds' if seconds.zero?

    parts = UNITS.filter_map do |name, size|
      count, seconds = seconds.divmod(size)
      "#{count} #{name}#{'s' unless count == 1}" if count.positive?
    end
    return parts.first if parts.size == 1

    "#{parts[0..-2].join(', ')}#{',' if parts.size > 2} and #{parts.last}"
  end
end
