require "test_helper"

class AdminOrdersControllerTest < ActionDispatch::IntegrationTest
  test "lists the day's orders" do
    get admin_orders_path(day: "2026-03-02")
    assert_response :success
    assert_select "tbody tr", 2
  end

  test "shows an order" do
    get admin_order_path(orders(:lea_morning))
    assert_select "li", text: "2 x Croissant"
  end
end
