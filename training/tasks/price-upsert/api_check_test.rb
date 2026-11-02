require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class PriceImportApiTest < Minitest::Test
  def test_uses_upsert_all
    assert_includes AnswerCalls.names(__dir__), :upsert_all
  end
end
