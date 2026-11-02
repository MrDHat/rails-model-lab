require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class BookListApiTest < Minitest::Test
  # Preloading the association, or one joined query that plucks both columns.
  def test_preloads_or_plucks_through_the_association
    names = AnswerCalls.names(__dir__)
    assert (names & %i[includes preload eager_load]).any? || (names.include?(:joins) && names.include?(:pluck))
  end
end
