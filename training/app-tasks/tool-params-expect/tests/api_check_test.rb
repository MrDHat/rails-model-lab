require "test_helper"
require_relative "app_calls"

class ToolParamsApiTest < ActiveSupport::TestCase
  test "uses params.expect" do
    assert_includes AnswerCalls.names, :expect
  end
end
