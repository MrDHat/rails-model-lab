require "test_helper"
require_relative "app_calls"

class ReceiptSignedLinkApiTest < ActiveSupport::TestCase
  test "uses Active Record signed ids" do
    assert (AnswerCalls.names & %i[find_signed find_signed!]).any?, "called #{AnswerCalls.names.inspect}"
  end
end
