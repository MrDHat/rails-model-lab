require "test_helper"
require_relative "app_calls"

class RelatedStoriesApiTest < ActiveSupport::TestCase
  test "the story itself is left out with excluding" do
    assert (AnswerCalls.names & %i[excluding without]).any?, "neither excluding nor without was called"
  end
end
