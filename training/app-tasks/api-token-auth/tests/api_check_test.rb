require "test_helper"
require_relative "app_calls"

class ApiTokenAuthApiTest < ActiveSupport::TestCase
  test "uses Rails' token authentication" do
    assert (AnswerCalls.names & %i[authenticate_with_http_token authenticate_or_request_with_http_token]).any?,
           "called #{AnswerCalls.names.inspect}"
  end
end
