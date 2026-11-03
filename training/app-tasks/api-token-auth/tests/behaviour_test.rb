require "test_helper"

class ApiTokenAuthTest < ActionDispatch::IntegrationTest
  def bearer(token) = { "Authorization" => "Bearer #{token}" }

  test "the key works from the Authorization header" do
    get api_products_path, headers: bearer("test-token"), as: :json
    assert_response :success
    post api_orders_path, params: { customer_email: "tom@example.com", items: [{ sku: "BAG", quantity: 1 }] },
                          headers: bearer("test-token"), as: :json
    assert_response :created
  end

  test "the query parameter still works" do
    get api_products_path(api_key: "test-token"), as: :json
    assert_response :success
  end

  test "a missing or wrong key is a 401 with a challenge" do
    [{}, bearer("nope")].each do |headers|
      get api_products_path, headers: headers, as: :json
      assert_response :unauthorized
      assert_equal 'Token realm="Crumb"', response.headers["WWW-Authenticate"]
    end
    get api_products_path(api_key: "nope"), as: :json
    assert_response :unauthorized
    assert_equal 'Token realm="Crumb"', response.headers["WWW-Authenticate"]
  end
end
