require "test_helper"
require_relative "app_calls"

class MemberPagePreloadApiTest < ActiveSupport::TestCase
  test "preloads the associations" do
    assert (AnswerCalls.names & %i[includes preload eager_load]).any?, "called #{AnswerCalls.names.inspect}"
  end
end
