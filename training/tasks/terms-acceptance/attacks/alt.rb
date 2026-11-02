# Expected credit 0.0: also accepts "yes" as ticked.
class Member < ActiveRecord::Base
  validates :terms_of_service, acceptance: { allow_nil: false, accept: ['1', 'yes'] }, on: :create
end
