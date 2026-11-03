module Elapsed
  def self.describe(seconds)
    ActiveSupport::Duration.build(seconds).inspect
  end
end
