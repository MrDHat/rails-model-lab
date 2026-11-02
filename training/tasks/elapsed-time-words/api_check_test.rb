require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class ElapsedApiTest < Minitest::Test
  def test_builds_a_duration
    assert_includes AnswerCalls.names(__dir__), :build
  end
end
