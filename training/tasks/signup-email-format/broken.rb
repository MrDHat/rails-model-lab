class Signup < ActiveRecord::Base
  validates :email, presence: true, format: { with: /@/ }
end
