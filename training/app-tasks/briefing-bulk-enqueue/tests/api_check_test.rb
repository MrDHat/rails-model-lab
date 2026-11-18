require "test_helper"
require_relative "app_calls"

class BriefingBulkEnqueueApiTest < ActiveSupport::TestCase
  test "deliveries are queued with ActiveJob.perform_all_later" do
    assert_includes AnswerCalls.names, :perform_all_later
  end
end
