require "test_helper"

class OverdueSweepJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper
  test "emails members with overdue loans" do
    loans(:ana_drill).update!(due_on: Date.current - 1)
    assert_enqueued_emails 1 do
      OverdueSweepJob.perform_now
    end
  end
end
