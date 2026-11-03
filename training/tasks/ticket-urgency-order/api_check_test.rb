require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class IssueOrderApiTest < Minitest::Test
  def test_uses_in_order_of
    assert_includes AnswerCalls.names(__dir__), :in_order_of
  end
end
