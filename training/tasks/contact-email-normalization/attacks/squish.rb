# Expected credit 1.0: squish instead of strip, still correct for these inputs.
class Contact < ActiveRecord::Base
  normalizes :email, with: ->(e) { e.squish.downcase }
  validates :email, presence: true
end
