require "test_helper"

class PatientAppointmentCountsApiTest < ActiveSupport::TestCase
  test "appointments keep a counter cache on their patient" do
    assert Appointment.reflect_on_association(:patient).options[:counter_cache], "no counter_cache on Appointment belongs_to :patient"
  end
end
