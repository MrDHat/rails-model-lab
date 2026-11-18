require "test_helper"

class AppointmentMailerTest < ActionMailer::TestCase
  test "confirmation" do
    mail = AppointmentMailer.confirmation(appointments(:julia_monday))
    assert_equal ["julia@example.com"], mail.to
    assert_equal "Your Mender appointment on Mon 15 Jun, 09:00", mail.subject
    assert_includes mail.body.to_s, "Your Physiotherapy session with Ana Souza is booked for Monday 15 June 2026 at 09:00 at Mender Paulista"
    assert_includes mail.body.to_s, "http://example.com/bookings/"
  end

  test "cancellation" do
    mail = AppointmentMailer.cancellation(appointments(:julia_monday))
    assert_equal ["julia@example.com"], mail.to
    assert_equal "Cancelled: your Mender appointment on Mon 15 Jun, 09:00", mail.subject
  end
end
