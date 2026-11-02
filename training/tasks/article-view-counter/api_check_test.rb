require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class StoryViewsApiTest < Minitest::Test
  def test_uses_counter_methods
    assert (AnswerCalls.names(__dir__) & %i[increment_counter update_counters increment!]).any?
  end
end
