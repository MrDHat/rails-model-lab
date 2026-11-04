require "test_helper"
require_relative "app_calls"

class SalesReportGroupApiTest < ActiveSupport::TestCase
  test "adds up with grouped Active Record calculations" do
    assert_includes AnswerCalls.names, :group
  end
end
