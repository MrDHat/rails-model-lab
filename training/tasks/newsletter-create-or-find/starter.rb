class Subscription < ActiveRecord::Base
end

module Newsletter
  def self.subscribe(email)
    Subscription.create!(email: email)
  end
end
