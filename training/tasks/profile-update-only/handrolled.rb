class Person < ActiveRecord::Base
  has_one :profile, dependent: :destroy, autosave: true

  def profile_attributes=(attributes)
    (profile || build_profile).assign_attributes(attributes)
  end
end

class Profile < ActiveRecord::Base
  belongs_to :person
end
