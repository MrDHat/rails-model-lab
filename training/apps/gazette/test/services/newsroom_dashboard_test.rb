require "test_helper"

class NewsroomDashboardTest < ActiveSupport::TestCase
  test "lists drafts, wire copy and scheduled stories separately" do
    dashboard = NewsroomDashboard.new
    assert_equal [articles(:ferry_strike)], dashboard.drafts.to_a
    assert_equal [articles(:wire_storm)], dashboard.wire_drafts.to_a
    assert_equal [articles(:night_market)], dashboard.scheduled.to_a
    assert_equal 1, dashboard.pending_comments
    assert_equal 1, dashboard.unread_letters
  end

  test "most read today counts Wellington's day" do
    assert_equal [articles(:harbour_bridge)], NewsroomDashboard.new.most_read_today.to_a
  end
end
