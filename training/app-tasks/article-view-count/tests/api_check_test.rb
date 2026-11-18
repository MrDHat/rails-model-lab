require "test_helper"
require_relative "app_calls"

class ArticleViewCountApiTest < ActiveSupport::TestCase
  test "views are added in the database with Active Record's counter methods" do
    articles(:harbour_bridge).record_view!
    assert (AnswerCalls.names & %i[increment! update_counters increment_counter]).any?,
           "none of increment!, update_counters or increment_counter was called"
  end
end
