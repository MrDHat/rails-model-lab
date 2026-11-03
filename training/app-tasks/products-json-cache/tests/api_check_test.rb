require "test_helper"
require_relative "app_calls"

class ProductsJsonCacheApiTest < ActiveSupport::TestCase
  test "reads through the cache with fetch" do
    assert_includes AnswerCalls.names, :fetch
  end
end
