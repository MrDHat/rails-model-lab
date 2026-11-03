require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class UnassignedApiTest < Minitest::Test
  # where.missing, or the left join it is built on.
  def test_uses_an_association_anti_join
    assert (AnswerCalls.names(__dir__) & %i[missing left_joins left_outer_joins]).any?
  end
end
