require "test_helper"

class SettingTest < ActiveSupport::TestCase
  test "falls back to defaults and stores JSON values" do
    assert_equal 5, Setting[:briefing_size]
    Setting[:briefing_size] = 3
    Setting[:comments_open] = false
    assert_equal 3, Setting[:briefing_size]
    assert_equal false, Setting["comments_open"]
  end
end
