require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class SettleJobApiTest < Minitest::Test
  def test_after_discard
    assert_includes AnswerCalls.names(__dir__), :after_discard
  end
end
