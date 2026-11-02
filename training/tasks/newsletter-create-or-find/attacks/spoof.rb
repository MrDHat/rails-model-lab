# Expected credit 0.1: find, create and rescue, plus a call that never runs.
class Subscription < ActiveRecord::Base
end

module Newsletter
  def self.subscribe(email)
    Subscription.find_by(email: email) || Subscription.create!(email: email)
  rescue ActiveRecord::RecordNotUnique
    Subscription.find_by!(email: email)
  end
end

if false
  create_or_find_by
end
