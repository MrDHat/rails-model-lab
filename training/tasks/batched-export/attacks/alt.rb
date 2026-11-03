# Expected credit 0.0: one unbounded pluck of every email.
class Subscriber < ActiveRecord::Base
end

module SubscriberExport
  def self.call(io)
    Subscriber.order(:id).pluck(:email).each { io.puts(_1) }
  end
end
