class Contact < ActiveRecord::Base
  normalizes :email, with: ->(value) { value.strip.downcase }
  validates :email, presence: true
end
