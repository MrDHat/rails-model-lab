require "test_helper"

class PatientPhoneFormatApiTest < ActiveSupport::TestCase
  test "patients normalize their phone attribute" do
    assert_equal "+5511987654321", Patient.normalize_value_for(:phone, "(11) 98765-4321")
  end
end
