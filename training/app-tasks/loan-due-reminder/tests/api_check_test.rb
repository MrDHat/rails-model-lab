require "test_helper"
require_relative "app_calls"

class LoanDueReminderApiTest < ActiveSupport::TestCase
  test "schedules the mail with deliver_later" do
    assert_includes AnswerCalls.names, :deliver_later
  end
end
