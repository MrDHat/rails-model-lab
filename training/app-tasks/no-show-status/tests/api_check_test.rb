require "test_helper"

class NoShowStatusApiTest < ActiveSupport::TestCase
  test "the status is an Active Record enum" do
    assert_equal({ "booked" => 0, "checked_in" => 1, "completed" => 2, "cancelled" => 3, "no_show" => 4 },
                 Appointment.defined_enums["status"]&.to_h { [_1.to_s, _2] })
  end
end
