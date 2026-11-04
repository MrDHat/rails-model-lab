require "test_helper"
require_relative "app_calls"

class ApiErrorsRescueFromApiTest < ActiveSupport::TestCase
  test "maps exceptions with rescue_from" do
    assert_includes AnswerCalls.names, :rescue_from
  end
end
