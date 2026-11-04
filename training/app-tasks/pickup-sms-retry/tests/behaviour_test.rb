require "test_helper"

class PickupSmsRetryTest < ActiveJob::TestCase
  setup do
    ActionMailer::Base.deliveries.clear
    @order = orders(:lea_morning)
  end

  test "a busy provider is tried again about 30 seconds later" do
    freeze_time
    SmsGateway.busy_for = 1
    PickupNotificationJob.perform_now(@order)
    retry_job = enqueued_jobs.sole
    assert_equal "PickupNotificationJob", retry_job[:job].name
    assert_in_delta 32, retry_job[:at] - Time.current.to_f, 3
  end

  test "the text gets through once the provider answers" do
    SmsGateway.busy_for = 3
    perform_enqueued_jobs { PickupNotificationJob.perform_later(@order) }
    assert_equal ["+33600000001"], SmsGateway.sent.map { _1[:to] }
    assert_empty ActionMailer::Base.deliveries
  end

  test "after five busy attempts it emails instead" do
    SmsGateway.busy_for = 10
    perform_enqueued_jobs { PickupNotificationJob.perform_later(@order) }
    assert_equal 5, SmsGateway.busy_for, "expected exactly 5 attempts"
    assert_empty SmsGateway.sent
    mail = ActionMailer::Base.deliveries.sole
    assert_equal ["lea@example.com"], mail.to
    assert_equal "Your Crumb order ##{@order.id} is ready", mail.subject
  end

  test "five attempts are enough" do
    SmsGateway.busy_for = 4
    perform_enqueued_jobs { PickupNotificationJob.perform_later(@order) }
    assert_equal 1, SmsGateway.sent.size
    assert_empty ActionMailer::Base.deliveries
  end
end
