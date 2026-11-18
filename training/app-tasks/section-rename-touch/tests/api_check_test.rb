require "test_helper"
require_relative "app_calls"

class SectionRenameTouchApiTest < ActiveSupport::TestCase
  test "the stories are touched with touch_all" do
    sections(:sport).update!(name: "Sports")
    assert_includes AnswerCalls.names, :touch_all
  end
end
