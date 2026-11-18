require "test_helper"
require_relative "app_calls"

class SchedulePageQueriesApiTest < ActiveSupport::TestCase
  test "preloads the associations with Active Record" do
    assert (AnswerCalls.names & %i[includes preload eager_load]).any?, "called #{AnswerCalls.names.inspect}"
  end
end
