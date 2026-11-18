require "test_helper"
require_relative "app_calls"

class BylineSentenceApiTest < ActiveSupport::TestCase
  test "names are joined with Array#to_sentence" do
    assert_includes AnswerCalls.names, :to_sentence
  end
end
