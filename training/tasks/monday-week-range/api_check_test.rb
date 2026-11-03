require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class WeekRangeApiTest < Minitest::Test
  def test_uses_week_helpers
    assert (AnswerCalls.names(__dir__) & %i[all_week beginning_of_week]).any?
  end
end
