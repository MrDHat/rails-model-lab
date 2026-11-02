class Subscription < ActiveRecord::Base
end

module Newsletter
  def self.subscribe(email)
    Subscription.create_or_find_by!(email: email)
  end
end
