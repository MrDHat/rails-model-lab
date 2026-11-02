class Member < ActiveRecord::Base
  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create
end
