require "test_helper"
require_relative "app_calls"

class MemberBanReturnsTransactionApiTest < ActiveSupport::TestCase
  test "bans inside a database transaction" do
    assert (AnswerCalls.names & %i[transaction with_lock]).any?, "called #{AnswerCalls.names.inspect}"
  end
end
