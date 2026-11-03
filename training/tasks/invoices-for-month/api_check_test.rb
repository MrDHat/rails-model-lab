require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class InvoiceMonthApiTest < Minitest::Test
  def test_uses_month_helpers
    assert (AnswerCalls.names(__dir__) & %i[all_month beginning_of_month end_of_month]).any?
  end
end
