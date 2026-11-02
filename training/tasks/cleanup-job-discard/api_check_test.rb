require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class CleanupJobApiTest < Minitest::Test
  def test_discard_on_is_declared
    assert_includes AnswerCalls.names(__dir__), :discard_on
    assert CleanupJob.rescue_handlers.any? { _1.first == 'ActiveRecord::RecordNotFound' }
  end
end
