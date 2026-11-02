class Subscriber < ActiveRecord::Base
end

module SubscriberExport
  def self.call(io)
    Subscriber.order(:id).each { io.puts(_1.email) }
  end
end
