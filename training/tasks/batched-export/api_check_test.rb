require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class ExportApiTest < Minitest::Test
  def test_uses_a_batch_method
    assert (AnswerCalls.names(__dir__) & %i[find_each find_in_batches in_batches]).any?
  end
end
