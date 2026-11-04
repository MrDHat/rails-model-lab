require "test_helper"

class PickupNotificationJobTest < ActiveJob::TestCase
  test "texts the customer" do
    PickupNotificationJob.perform_now(orders(:lea_morning))
    assert_match "ready to collect", SmsGateway.sent.sole[:body]
  end

  test "skips customers without a phone" do
    PickupNotificationJob.perform_now(orders(:tom_evening))
    assert_empty SmsGateway.sent
  end
end
