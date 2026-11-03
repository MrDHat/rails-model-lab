class Subscription < ActiveRecord::Base
end

module Newsletter
  def self.subscribe(email)
    Subscription.find_by(email: email) || Subscription.create!(email: email)
  rescue ActiveRecord::RecordNotUnique
    Subscription.find_by!(email: email)
  end
end
