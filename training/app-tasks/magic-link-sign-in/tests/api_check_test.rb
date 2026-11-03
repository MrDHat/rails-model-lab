require "test_helper"
require_relative "app_calls"

class MagicLinkSignInApiTest < ActiveSupport::TestCase
  test "uses Active Record's generated tokens" do
    assert (AnswerCalls.names & %i[find_by_token_for find_by_token_for!]).any?, "called #{AnswerCalls.names.inspect}"
  end
end
