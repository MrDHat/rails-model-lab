# Expected credit 0.0: find then create with no recovery from a competing insert.
class Subscription < ActiveRecord::Base
end

module Newsletter
  def self.subscribe(email)
    Subscription.find_by(email: email) || Subscription.create!(email: email)
  end
end
