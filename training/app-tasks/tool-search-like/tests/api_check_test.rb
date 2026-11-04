require "test_helper"
require_relative "app_calls"

class ToolSearchLikeApiTest < ActiveSupport::TestCase
  test "escapes the pattern with Active Record" do
    assert_includes AnswerCalls.names, :sanitize_sql_like
  end
end
