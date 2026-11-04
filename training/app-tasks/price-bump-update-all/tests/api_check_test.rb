require "test_helper"
require_relative "app_calls"

class PriceBumpUpdateAllApiTest < ActiveSupport::TestCase
  test "updates with update_all" do
    assert_includes AnswerCalls.names, :update_all
  end
end
