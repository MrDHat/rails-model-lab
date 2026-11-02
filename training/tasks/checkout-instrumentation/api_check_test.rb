require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class CheckoutEventApiTest < Minitest::Test
  def test_uses_instrument
    assert_includes AnswerCalls.names(__dir__), :instrument
  end
end
