require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class PriceListApiTest < Minitest::Test
  def test_uses_fetch_multi
    assert_includes AnswerCalls.names(__dir__), :fetch_multi
  end
end
