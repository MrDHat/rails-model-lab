require "test_helper"

class ApiErrorsRescueFromTest < ActionDispatch::IntegrationTest
  def assert_error(status, message)
    assert_response status
    assert_equal "application/json", response.media_type
    assert_equal({ "error" => message }, response.parsed_body)
  end

  test "unknown records are 404" do
    get api_product_path("NOPE", api_key: api_key), as: :json
    assert_error :not_found, "Not found"
    get api_order_path(0, api_key: api_key), as: :json
    assert_error :not_found, "Not found"
    patch api_order_path(0, api_key: api_key), params: { status: 1 }, as: :json
    assert_error :not_found, "Not found"
  end

  test "unknown customers and SKUs in a new order are 404" do
    post api_orders_path(api_key: api_key), params: { customer_email: "who@example.com", items: [{ sku: "CRO", quantity: 1 }] }, as: :json
    assert_error :not_found, "Not found"
    assert_no_difference -> { Order.count } do
      post api_orders_path(api_key: api_key), params: { customer_email: "tom@example.com", items: [{ sku: "ECL", quantity: 1 }] }, as: :json
    end
    assert_error :not_found, "Not found"
  end

  test "missing parameters are 400" do
    post api_orders_path(api_key: api_key), params: { customer_email: "tom@example.com" }, as: :json
    assert_error :bad_request, "param is missing or the value is empty or invalid: items"
    patch api_order_path(orders(:lea_morning), api_key: api_key), params: {}, as: :json
    assert_error :bad_request, "param is missing or the value is empty or invalid: status"
  end

  test "invalid records are 422" do
    assert_no_difference -> { Order.count } do
      post api_orders_path(api_key: api_key), params: { customer_email: "tom@example.com", items: [{ sku: "CRO", quantity: 0 }] }, as: :json
    end
    assert_error :unprocessable_entity, "Validation failed: Quantity must be greater than 0"
  end

  test "a bad key is still a bare 401" do
    get api_product_path("NOPE", api_key: "wrong"), as: :json
    assert_response :unauthorized
    assert_empty response.body
  end
end
