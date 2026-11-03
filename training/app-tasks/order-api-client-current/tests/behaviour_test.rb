require "test_helper"

class OrderApiClientCurrentTest < ActionDispatch::IntegrationTest
  setup { @kiosk = ApiClient.create!(name: "Kiosk", token: "kiosk-token") }

  def place(token)
    post api_orders_path(api_key: token), params: { customer_email: "tom@example.com", items: [{ sku: "CRO", quantity: 1 }] }, as: :json
    assert_response :created
    Order.find(response.parsed_body["id"])
  end

  test "orders placed through the API record the client" do
    assert_equal @kiosk, place("kiosk-token").api_client
    assert_equal api_clients(:app), place(api_key).api_client
  end

  test "orders created outside a request have no client" do
    place("kiosk-token")
    order = Order.place!(customer: customers(:lea), items: [{ sku: "BAG", quantity: 1 }])
    assert_nil order.reload.api_client
  end
end
