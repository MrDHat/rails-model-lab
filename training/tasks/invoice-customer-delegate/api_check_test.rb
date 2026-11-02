require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class BillClientApiTest < Minitest::Test
  def test_uses_delegate
    assert_includes AnswerCalls.names(__dir__), :delegate
  end
end
