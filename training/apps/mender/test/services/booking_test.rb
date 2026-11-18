require "test_helper"

class BookingTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup { travel_to Time.utc(2026, 6, 14, 12) }
  teardown { travel_back }

  def book(**overrides)
    Booking.create!(patient: patients(:tom), practitioner: practitioners(:ana), treatment: treatments(:physio),
                    starts_at: Time.utc(2026, 6, 15, 17), **overrides)
  end

  test "takes a free room and emails a confirmation" do
    appointment = nil
    assert_enqueued_emails(1) { appointment = book }
    assert_enqueued_email_with AppointmentMailer, :confirmation, args: [appointment]
    assert_equal rooms(:paulista_1), appointment.room
    assert_equal "app", appointment.source
  end

  test "uses another room when the first is taken, or none when all are" do
    assert_equal rooms(:paulista_2), book(practitioner: practitioners(:bruno), starts_at: Time.utc(2026, 6, 15, 12)).room
    assert_nil book(patient: patients(:julia), practitioner: practitioners(:bruno), starts_at: Time.utc(2026, 6, 15, 12, 30)).room
  end

  test "takes the patient off the practitioner's waitlist" do
    assert_difference -> { WaitlistEntry.count }, -1 do
      book
    end
  end

  test "refuses inactive practitioners and archived patients" do
    assert_raises(Booking::Unavailable) { book(practitioner: practitioners(:diego), treatment: treatments(:massage)) }
    assert_raises(Booking::Unavailable) { book(patient: patients(:rita)) }
  end
end
