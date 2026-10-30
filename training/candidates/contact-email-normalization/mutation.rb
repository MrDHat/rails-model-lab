class Contact < ActiveRecord::Base
  before_validation { self.email = email&.strip&.downcase }
  validates :email, presence: true
end
