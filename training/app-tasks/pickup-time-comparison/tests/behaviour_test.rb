require "test_helper"

class PickupTimeComparisonTest < ActionDispatch::IntegrationTest
  setup { travel_to Time.utc(2026, 4, 1, 8) }
  teardown { travel_back }

  def build(pickup_at) = Order.new(customer: customers(:tom), placed_at: Time.current, pickup_at: pickup_at)

  def place(pickup_at)
    post api_orders_path(api_key: api_key), params: { customer_email: "tom@example.com", items: [{ sku: "CRO", quantity: 1 }],
                                                      pickup_at: pickup_at&.iso8601 }, as: :json
  end

  test "a pickup time in the window is fine" do
    assert build(2.hours.from_now).valid?
    assert build(7.days.from_now).valid?
    assert build(nil).valid?
  end

  test "a pickup time before the order is refused" do
    order = build(1.minute.ago)
    assert_not order.valid?
    assert_equal ["Pickup at must be after the order is placed"], order.errors.full_messages
    assert_not build(Time.current).valid?
  end

  test "a pickup time more than a week out is refused" do
    order = build(7.days.from_now + 1.minute)
    assert_not order.valid?
    assert_equal ["Pickup at must be within 7 days of the order"], order.errors.full_messages
  end

  test "the API answers 422 with the errors" do
    assert_no_difference -> { Order.count } do
      place(1.hour.ago)
    end
    assert_response :unprocessable_entity
    assert_equal({ "errors" => ["Pickup at must be after the order is placed"] }, response.parsed_body)
    place(10.days.from_now)
    assert_equal({ "errors" => ["Pickup at must be within 7 days of the order"] }, response.parsed_body)
    place(3.hours.from_now)
    assert_response :created
    place(nil)
    assert_response :created
  end
end
