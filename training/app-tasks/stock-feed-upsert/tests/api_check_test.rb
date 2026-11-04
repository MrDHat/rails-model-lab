require "test_helper"
require_relative "app_calls"

class StockFeedUpsertApiTest < ActiveSupport::TestCase
  test "writes with Active Record's bulk upsert" do
    assert_includes AnswerCalls.names, :upsert_all
  end
end
