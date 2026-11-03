require "test_helper"

class ApiOrdersControllerTest < ActionDispatch::IntegrationTest
  test "rejects a missing or wrong key" do
    get api_order_path(orders(:lea_morning)), as: :json
    assert_response :unauthorized
    get api_order_path(orders(:lea_morning), api_key: "nope"), as: :json
    assert_response :unauthorized
  end

  test "creates an order" do
    post api_orders_path(api_key: api_key), params: { customer_email: "tom@example.com", items: [{ sku: "CRO", quantity: 2 }] }, as: :json
    assert_response :created
    assert_equal 280, response.parsed_body["total_cents"]
  end

  test "shows an order" do
    get api_order_path(orders(:lea_morning), api_key: api_key), as: :json
    assert_equal %w[BAG CRO], response.parsed_body["items"].map { _1["sku"] }.sort
  end

  test "marking an order ready texts the customer" do
    perform_enqueued_jobs do
      patch api_order_path(orders(:lea_morning), api_key: api_key), params: { status: Order::READY }, as: :json
    end
    assert_response :success
    assert_equal ["+33600000001"], SmsGateway.sent.map { _1[:to] }
  end
end
