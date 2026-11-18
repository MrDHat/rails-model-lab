require "test_helper"

class ScheduleTest < ActiveSupport::TestCase
  test "a location's day in clinic time" do
    schedule = Schedule.new(locations(:paulista), Date.new(2026, 6, 15))
    assert_equal [appointments(:julia_monday), appointments(:tom_monday), appointments(:marcos_monday)], schedule.appointments.to_a
    assert_equal [practitioners(:ana), practitioners(:bruno)], schedule.by_practitioner.keys
  end

  test "late evening appointments stay on their day" do
    late = Appointment.create!(patient: patients(:tom), practitioner: practitioners(:bruno), treatment: treatments(:physio),
                               starts_at: Time.utc(2026, 6, 16, 1, 30))
    assert_includes Schedule.new(locations(:paulista), Date.new(2026, 6, 15)).appointments, late
    assert_not_includes Schedule.new(locations(:paulista), Date.new(2026, 6, 16)).appointments, late
  end
end
