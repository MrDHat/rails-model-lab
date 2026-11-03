# Expected credit 0.1: manual joining plus a to_sentence that never runs.
module Attendees
  def self.summary(names)
    case names.size
    when 0 then ''
    when 1 then names.first
    when 2 then names.join(' and ')
    else "#{names[0..-2].join(', ')}, and #{names.last}"
    end
  end
end

if false
  to_sentence
end
