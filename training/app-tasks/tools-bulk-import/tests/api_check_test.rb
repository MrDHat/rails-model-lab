require "test_helper"
require_relative "app_calls"

class ToolsBulkImportApiTest < ActiveSupport::TestCase
  test "inserts with Active Record's bulk insert" do
    assert (AnswerCalls.names & %i[insert_all insert_all! upsert_all]).any?, "called #{AnswerCalls.names.inspect}"
  end
end
