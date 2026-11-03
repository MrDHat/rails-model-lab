class Subscriber < ActiveRecord::Base
end

module SubscriberExport
  def self.call(io)
    last_id = 0
    loop do
      rows = Subscriber.where('id > ?', last_id).order(:id).limit(500).to_a
      break if rows.empty?
      rows.each { io.puts(_1.email) }
      last_id = rows.last.id
    end
  end
end
