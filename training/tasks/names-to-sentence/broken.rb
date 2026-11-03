module Attendees
  def self.summary(names)
    names.size > 1 ? "#{names[0..-2].join(', ')} and #{names.last}" : names.first.to_s
  end
end
