require "test_helper"
require_relative "app_calls"

class PickupSmsRetryApiTest < ActiveSupport::TestCase
  test "retries with Active Job's retry_on" do
    assert_includes AnswerCalls.names, :retry_on
  end
end
