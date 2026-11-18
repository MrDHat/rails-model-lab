require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  setup { travel_to Time.utc(2026, 6, 14, 12) }
  teardown { travel_back }

  test "ends when the treatment does" do
    appointment = Appointment.create!(patient: patients(:tom), practitioner: practitioners(:ana), treatment: treatments(:sports_massage),
                                      starts_at: Time.utc(2026, 6, 17, 12))
    assert_equal Time.utc(2026, 6, 17, 12, 30), appointment.ends_at
  end

  test "the practitioner must offer the treatment" do
    appointment = Appointment.new(patient: patients(:tom), practitioner: practitioners(:ana), treatment: treatments(:pilates),
                                  starts_at: Time.utc(2026, 6, 17, 12))
    assert_not appointment.valid?
    assert_equal ["Treatment is not offered by Ana Souza"], appointment.errors.full_messages
  end

  test "moves from booked to checked in to completed" do
    appointment = appointments(:julia_monday)
    appointment.check_in!
    assert appointment.checked_in?
    appointment.complete!
    assert_equal "completed", appointment.reload.status_name
  end

  test "can't complete without checking in" do
    assert_raises(Appointment::InvalidTransition) { appointments(:julia_monday).complete! }
  end

  test "cancelling records why and when" do
    appointment = appointments(:julia_monday)
    appointment.cancel!(reason: "Feeling better")
    appointment.reload
    assert appointment.cancelled?
    assert_equal "Feeling better", appointment.cancellation_reason
    assert_equal Time.current, appointment.cancelled_at
  end

  test "only booked appointments can be cancelled" do
    assert_raises(Appointment::InvalidTransition) { appointments(:julia_last_week).cancel!(reason: "x") }
  end

  test "status changes are audited" do
    appointments(:julia_monday).check_in!
    event = AuditEvent.last
    assert_equal "appointment.checked_in", event.action
    assert_equal({ "from" => "booked" }, event.details)
    assert_equal appointments(:julia_monday), event.subject
  end

  test "rescheduling keeps the length" do
    appointment = appointments(:julia_monday)
    appointment.reschedule!(Time.utc(2026, 6, 17, 13))
    assert_equal Time.utc(2026, 6, 17, 13, 45), appointment.reload.ends_at
  end
end
