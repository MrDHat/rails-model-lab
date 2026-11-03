module Elapsed
  def self.describe(seconds)
    hours, rest = seconds.divmod(3600)
    minutes, secs = rest.divmod(60)
    [[hours, 'hours'], [minutes, 'minutes'], [secs, 'seconds']].reject { _1.first.zero? }.map { _1.join(' ') }.join(' and ')
  end
end
