require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class NewsletterApiTest < Minitest::Test
  def test_uses_create_or_find_by
    assert (AnswerCalls.names(__dir__) & %i[create_or_find_by create_or_find_by!]).any?
  end
end
