require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class AttendeesApiTest < Minitest::Test
  def test_uses_to_sentence
    assert_includes AnswerCalls.names(__dir__), :to_sentence
  end
end
