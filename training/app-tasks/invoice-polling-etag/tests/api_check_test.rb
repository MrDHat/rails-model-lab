require "test_helper"
require_relative "app_calls"

class InvoicePollingEtagApiTest < ActiveSupport::TestCase
  test "uses Rails' conditional GET helpers" do
    assert (AnswerCalls.names & %i[fresh_when stale?]).any?, "called #{AnswerCalls.names.inspect}"
  end
end
