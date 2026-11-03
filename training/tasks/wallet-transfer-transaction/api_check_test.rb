require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class TransferApiTest < Minitest::Test
  def test_uses_transaction
    assert_includes AnswerCalls.names(__dir__), :transaction
  end
end
