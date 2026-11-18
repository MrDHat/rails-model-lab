require "test_helper"
require_relative "app_calls"

class ArticleSlugsApiTest < ActiveSupport::TestCase
  test "slugs come from String#parameterize" do
    assert_includes AnswerCalls.names, :parameterize
  end
end
