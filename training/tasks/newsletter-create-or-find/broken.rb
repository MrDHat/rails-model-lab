class Subscription < ActiveRecord::Base
  validates :email, uniqueness: true
end

module Newsletter
  def self.subscribe(email)
    Subscription.create!(email: email)
  end
end
