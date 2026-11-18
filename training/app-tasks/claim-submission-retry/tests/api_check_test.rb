require "test_helper"
require_relative "app_calls"

class ClaimSubmissionRetryApiTest < ActiveSupport::TestCase
  test "uses Active Job's retry_on" do
    assert_includes AnswerCalls.names, :retry_on
  end
end
