require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class BookListApiTest < Minitest::Test
  def test_preloads
    assert (AnswerCalls.names(__dir__) & %i[includes preload eager_load]).any?
  end
end
