# Expected credit 1.0: normalizes with apply_to_nil, still correct.
class Contact < ActiveRecord::Base
  normalizes :email, with: ->(e) { e.to_s.strip.downcase.presence }, apply_to_nil: true
  validates :email, presence: true
end
