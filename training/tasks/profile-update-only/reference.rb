class Person < ActiveRecord::Base
  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile, update_only: true
end

class Profile < ActiveRecord::Base
  belongs_to :person
end
