require "test_helper"

class DailyRemindersJobTest < ActiveJob::TestCase
  test "queues a reminder for each of tomorrow's appointments" do
    travel_to Time.utc(2026, 6, 14, 21) do
      DailyRemindersJob.perform_now
    end
    assert_equal [appointments(:julia_monday), appointments(:tom_monday), appointments(:marcos_monday)].sort_by(&:id),
                 enqueued_jobs.select { _1[:job] == AppointmentReminderJob }.map { GlobalID::Locator.locate(_1[:args].first["_aj_globalid"]) }.sort_by(&:id)
  end
end
