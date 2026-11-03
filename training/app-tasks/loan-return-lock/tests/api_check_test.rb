require "test_helper"
require_relative "app_calls"

class LoanReturnLockApiTest < ActiveSupport::TestCase
  test "locks the loan row while returning it" do
    assert (AnswerCalls.names & %i[with_lock lock!]).any?, "called #{AnswerCalls.names.inspect}"
  end
end
