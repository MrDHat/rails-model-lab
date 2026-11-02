require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class BillingDateApiTest < Minitest::Test
  def test_uses_active_support_month_arithmetic
    assert (AnswerCalls.names(__dir__) & %i[next_month advance months_since integer.month integer.months]).any?
  end
end
