require "test_helper"

class NoDoubleBookingApiTest < ActiveSupport::TestCase
  test "start times are unique per practitioner through a uniqueness validation" do
    validator = Appointment.validators_on(:starts_at).find { _1.is_a?(ActiveRecord::Validations::UniquenessValidator) }
    assert validator, "no uniqueness validation on starts_at"
    assert_includes Array(validator.options[:scope]).map(&:to_sym), :practitioner_id
  end
end
