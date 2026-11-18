require "test_helper"
require_relative "app_calls"

class NeverBookedPatientsApiTest < ActiveSupport::TestCase
  test "finds patients without appointments with where.missing" do
    assert_includes AnswerCalls.names, :missing
  end
end
