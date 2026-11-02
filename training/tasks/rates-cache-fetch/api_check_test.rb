require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class RateCardApiTest < Minitest::Test
  def test_uses_fetch
    assert_includes AnswerCalls.names(__dir__), :fetch
  end
end
