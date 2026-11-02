require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class NewsletterApiTest < Minitest::Test
  # find_or_create_by falls back to create_or_find_by since Rails 8.0.
  def test_uses_create_or_find_by
    assert (AnswerCalls.names(__dir__) & %i[create_or_find_by create_or_find_by! find_or_create_by find_or_create_by!]).any?
  end
end
