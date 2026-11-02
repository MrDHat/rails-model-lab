require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class UnassignedApiTest < Minitest::Test
  def test_uses_where_missing
    assert_includes AnswerCalls.names(__dir__), :missing
  end
end
