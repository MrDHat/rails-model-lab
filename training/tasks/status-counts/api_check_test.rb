require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class StatusCountsApiTest < Minitest::Test
  def test_groups_and_counts
    names = AnswerCalls.names(__dir__)
    assert_includes names, :group
    assert_includes names, :count
  end
end
