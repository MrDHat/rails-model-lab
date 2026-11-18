require "test_helper"
require_relative "app_calls"

class ArticleCdnCacheApiTest < ActiveSupport::TestCase
  test "the cache lifetime is set with expires_in" do
    assert_includes AnswerCalls.names, :expires_in
  end
end
