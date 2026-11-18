require "test_helper"
require_relative "app_calls"

class FrontPageOrderApiTest < ActiveSupport::TestCase
  test "the database orders the sections with in_order_of" do
    Setting[:front_page_order] = %w[sport news]
    FrontPage.new.blocks
    assert_includes AnswerCalls.names, :in_order_of
  end
end
