class Subscriber < ActiveRecord::Base
end

module SubscriberExport
  def self.call(io)
    Subscriber.find_each(batch_size: 500) { io.puts(_1.email) }
  end
end
