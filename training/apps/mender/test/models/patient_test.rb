require "test_helper"

class PatientTest < ActiveSupport::TestCase
  test "emails are unique whatever the case" do
    patient = Patient.new(name: "J", email: "JULIA@example.com", phone: "+5511900000000")
    assert_not patient.valid?
    assert_includes patient.errors.full_messages, "Email has already been taken"
  end

  test "searches by name, email or phone" do
    assert_equal [patients(:julia)], Patient.search("Costa").to_a
    assert_equal [patients(:tom)], Patient.search("tom@").to_a
    assert_equal [patients(:marcos)], Patient.search("987650002").to_a
  end

  test "the current policy is the one valid that day" do
    assert_equal insurance_policies(:julia_saude), patients(:julia).current_policy(on: Date.new(2026, 6, 1))
    assert_nil patients(:lucia).current_policy(on: Date.new(2026, 6, 1))
    assert_equal insurance_policies(:lucia_vida), patients(:lucia).current_policy(on: Date.new(2026, 3, 1))
  end
end
