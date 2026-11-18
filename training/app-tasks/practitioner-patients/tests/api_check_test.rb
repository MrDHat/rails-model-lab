require "test_helper"

class PractitionerPatientsApiTest < ActiveSupport::TestCase
  test "patients is a has_many :through association" do
    reflection = Practitioner.reflect_on_association(:patients)
    assert reflection&.through_reflection?, "Practitioner#patients isn't a has_many :through"
  end
end
