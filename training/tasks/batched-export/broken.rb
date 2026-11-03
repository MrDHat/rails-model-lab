class Subscriber < ActiveRecord::Base
end

module SubscriberExport
  def self.call(io)
    Subscriber.order(:id).to_a.each_slice(500) { |slice| slice.each { io.puts(_1.email) } }
  end
end
