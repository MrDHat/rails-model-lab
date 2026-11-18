require "test_helper"

class AppointmentReminderJobTest < ActiveJob::TestCase
  test "texts the patient" do
    AppointmentReminderJob.perform_now(appointments(:julia_monday))
    assert_equal [{ to: "+5511987650001",
                    body: "Hi Julia, a reminder of your appointment with Ana Souza on Mon 15 Jun, 09:00 at Mender Paulista. Reply C to cancel." }],
                 SmsGateway.sent
  end

  test "not for cancelled appointments" do
    AppointmentReminderJob.perform_now(appointments(:marcos_cancelled))
    assert_empty SmsGateway.sent
  end
end
