require "test_helper"

class OrderStatusEnumTest < ActionDispatch::IntegrationTest
  def stored_status(order) = Order.connection.select_value("SELECT status FROM orders WHERE id = #{order.id}")

  def set_status(order, status)
    patch api_order_path(order, api_key: api_key), params: { status: status }, as: :json
  end

  test "the JSON names the status" do
    get api_order_path(orders(:tom_evening), api_key: api_key), as: :json
    assert_equal "collected", response.parsed_body["status"]
  end

  test "takes a status name and stores the same number" do
    set_status(orders(:lea_morning), "baking")
    assert_response :success
    assert_equal "baking", response.parsed_body["status"]
    assert_equal 1, stored_status(orders(:lea_morning))
  end

  test "still takes numbers" do
    set_status(orders(:lea_morning), 4)
    assert_response :success
    assert_equal "cancelled", response.parsed_body["status"]
    assert_equal 2, Order::READY
  end

  test "an unknown status is refused" do
    ["burnt", 9].each do |status|
      set_status(orders(:lea_morning), status)
      assert_response :unprocessable_entity
      assert_equal({ "error" => "Status is not included in the list" }, response.parsed_body)
      assert_equal 0, stored_status(orders(:lea_morning))
    end
  end

  test "ready still texts the customer" do
    perform_enqueued_jobs { set_status(orders(:lea_morning), "ready") }
    assert_equal 1, SmsGateway.sent.size
  end

  test "scopes and predicates" do
    assert_equal [orders(:tom_evening)], Order.collected.to_a
    assert_equal [orders(:lea_morning)], Order.placed.to_a
    assert orders(:lea_morning).placed?
    assert_not orders(:lea_morning).ready?
  end
end
