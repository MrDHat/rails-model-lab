require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class PriceWidgetApiTest < Minitest::Test
  def test_uses_handle
    assert_includes AnswerCalls.names(__dir__), :handle
  end
end
