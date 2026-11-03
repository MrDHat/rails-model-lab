require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class InviteCodeApiTest < Minitest::Test
  def test_uses_has_secure_token
    assert_includes AnswerCalls.names(__dir__), :has_secure_token
  end
end
