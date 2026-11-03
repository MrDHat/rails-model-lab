class Person < ActiveRecord::Base
  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile, reject_if: :all_blank
end

class Profile < ActiveRecord::Base
  belongs_to :person
end
