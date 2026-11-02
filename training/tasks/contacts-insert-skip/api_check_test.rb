require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class LeadImportApiTest < Minitest::Test
  def test_uses_insert_all
    assert_includes AnswerCalls.names(__dir__), :insert_all
  end
end
