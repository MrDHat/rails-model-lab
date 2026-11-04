require "test_helper"

class CheckoutFormObjectTest < ActionDispatch::IntegrationTest
  def checkout(**body)
    assert_no_difference(-> { Order.count }) do
      post api_orders_path(api_key: api_key), params: body, as: :json
    end
    assert_response :unprocessable_entity
    response.parsed_body["errors"]
  end

  test "every problem at once" do
    errors = checkout(customer_email: "who@example.com", items: [{ sku: "CRO", quantity: 30 }, { sku: "ECL", quantity: 1 }, { sku: "XYZ", quantity: 1 }],
                      pickup_at: "tomorrow-ish")
    assert_equal ["is not a customer"], errors["customer_email"]
    assert_equal ["has an unknown product: ECL", "has an unknown product: XYZ", "has a quantity outside 1 to 20"].sort, errors["items"].sort
    assert_equal ["is not a valid time"], errors["pickup_at"]
  end

  test "missing fields" do
    assert_equal({ "customer_email" => ["can't be blank"], "items" => ["can't be blank"] }, checkout(notes: "hi"))
  end

  test "quantities must be whole numbers from 1 to 20" do
    [0, 21, "two", 2.5].each do |quantity|
      assert_equal({ "items" => ["has a quantity outside 1 to 20"] }, checkout(customer_email: "tom@example.com", items: [{ sku: "CRO", quantity: quantity }]))
    end
  end

  test "a valid request places the order" do
    post api_orders_path(api_key: api_key), params: { customer_email: "tom@example.com", items: [{ sku: "CRO", quantity: 20 }, { sku: "BAG", quantity: 1 }],
                                                      pickup_at: "2026-04-01T09:30:00+02:00", notes: "Ring twice" }, as: :json
    assert_response :created
    order = Order.find(response.parsed_body["id"])
    assert_equal [2920, Time.utc(2026, 4, 1, 7, 30), "Ring twice", customers(:tom)], [order.total_cents, order.pickup_at, order.notes, order.customer]
  end
end
