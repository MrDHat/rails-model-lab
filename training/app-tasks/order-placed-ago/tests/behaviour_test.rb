require "test_helper"

class OrderPlacedAgoTest < ActionDispatch::IntegrationTest
  setup { travel_to Time.utc(2026, 6, 10, 12) }

  teardown { travel_back }

  def waiting_for(placed_at)
    order = Order.create!(customer: customers(:tom), placed_at: placed_at)
    get admin_orders_path(day: placed_at.utc.to_date.iso8601)
    headers = css_select("thead th").map { _1.text.strip }
    column = headers.index("Waiting") or flunk("no Waiting column in #{headers}")
    assert_equal "Placed", headers[column - 1]
    css_select("##{ActionView::RecordIdentifier.dom_id(order)} td")[column].text.strip
  end

  test "words the wait like Rails" do
    assert_equal "less than a minute ago", waiting_for(20.seconds.ago)
    assert_equal "1 minute ago", waiting_for(70.seconds.ago)
    assert_equal "25 minutes ago", waiting_for(25.minutes.ago)
    assert_equal "about 1 hour ago", waiting_for(62.minutes.ago)
    assert_equal "about 2 hours ago", waiting_for(130.minutes.ago)
    assert_equal "1 day ago", waiting_for(26.hours.ago)
    assert_equal "3 days ago", waiting_for(3.days.ago)
  end
end
