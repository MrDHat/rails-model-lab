require "test_helper"
require_relative "app_calls"

class OrdersExportBatchesApiTest < ActiveSupport::TestCase
  test "walks the orders with Active Record batches" do
    assert (AnswerCalls.names & %i[find_each find_in_batches in_batches]).any?, "called #{AnswerCalls.names.inspect}"
  end
end
