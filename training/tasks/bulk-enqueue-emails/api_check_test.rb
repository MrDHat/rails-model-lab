require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class DigestApiTest < Minitest::Test
  def test_uses_perform_all_later
    assert_includes AnswerCalls.names(__dir__), :perform_all_later
  end
end
