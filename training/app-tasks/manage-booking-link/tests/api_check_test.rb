require "test_helper"

class ManageBookingLinkApiTest < ActiveSupport::TestCase
  test "appointments generate their tokens with generates_token_for" do
    assert Appointment.respond_to?(:token_definitions) && Appointment.token_definitions.any?, "no generates_token_for on Appointment"
  end
end
