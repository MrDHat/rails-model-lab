require "test_helper"
require_relative "app_calls"

class SlotSearchRateLimitApiTest < ActiveSupport::TestCase
  test "uses the controller rate limiter" do
    assert_includes AnswerCalls.names, :rate_limit
  end
end
