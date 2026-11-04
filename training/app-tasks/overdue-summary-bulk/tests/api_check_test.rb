require "test_helper"
require_relative "app_calls"

class OverdueSummaryBulkApiTest < ActiveSupport::TestCase
  test "enqueues the emails in bulk" do
    assert (AnswerCalls.names & %i[deliver_all_later perform_all_later]).any?, "called #{AnswerCalls.names.inspect}"
  end
end
