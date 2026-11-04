require "test_helper"

class OrdersParisDayTest < ActionDispatch::IntegrationTest
  def place(at) = Order.create!(customer: customers(:tom), placed_at: at)

  def listed(day)
    get admin_orders_path(day: day)
    assert_response :success
    css_select("tbody tr").map { _1["id"].delete_prefix("order_").to_i }.sort
  end

  test "winter days run midnight to midnight Paris time" do
    late = place(Time.utc(2026, 3, 2, 22, 59))
    early = place(Time.utc(2026, 3, 2, 23, 30))
    assert_equal [orders(:lea_morning), orders(:tom_evening), late].map(&:id).sort, listed("2026-03-02")
    assert_equal [early.id], listed("2026-03-03")
  end

  test "summer days too" do
    late = place(Time.utc(2026, 7, 14, 21, 50))
    early = place(Time.utc(2026, 7, 14, 22, 15))
    assert_equal [late.id], listed("2026-07-14")
    assert_equal [early.id], listed("2026-07-15")
  end

  test "the clock-change day" do
    before = place(Time.utc(2026, 3, 28, 23, 10))
    after = place(Time.utc(2026, 3, 29, 21, 50))
    next_day = place(Time.utc(2026, 3, 29, 22, 5))
    assert_equal [before.id, after.id].sort, listed("2026-03-29")
    assert_equal [next_day.id], listed("2026-03-30")
  end
end
