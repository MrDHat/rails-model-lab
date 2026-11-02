# Expected credit 1.0: find_or_create_by!, which recovers from the conflict since Rails 8.0.
class Subscription < ActiveRecord::Base
end

module Newsletter
  def self.subscribe(email)
    Subscription.find_or_create_by!(email: email)
  end
end
