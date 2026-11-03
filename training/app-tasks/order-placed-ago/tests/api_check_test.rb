require "test_helper"
require_relative "app_calls"

class OrderPlacedAgoApiTest < ActiveSupport::TestCase
  test "uses the date helpers" do
    assert (AnswerCalls.names & %i[time_ago_in_words distance_of_time_in_words distance_of_time_in_words_to_now]).any?,
           "called #{AnswerCalls.names.inspect}"
  end
end
