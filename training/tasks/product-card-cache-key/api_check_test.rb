require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class ProductCardKeyApiTest < Minitest::Test
  def test_uses_record_cache_key
    assert (AnswerCalls.names(__dir__) & %i[cache_key_with_version cache_version]).any?
  end
end
