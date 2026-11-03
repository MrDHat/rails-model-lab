require "test_helper"

class ApiProductsControllerTest < ActionDispatch::IntegrationTest
  test "lists active products" do
    get api_products_path(api_key: api_key), as: :json
    assert_equal %w[BAG CRO], response.parsed_body.map { _1["sku"] }
  end

  test "shows a product by sku" do
    get api_product_path("CRO", api_key: api_key), as: :json
    assert_equal 140, response.parsed_body["price_cents"]
  end
end
