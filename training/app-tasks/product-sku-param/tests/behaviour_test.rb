require "test_helper"

class ProductSkuParamTest < ActionDispatch::IntegrationTest
  test "the product list links by SKU" do
    get products_path
    assert_equal ["/products/bag", "/products/cro"], css_select("a[href^='/products/']").map { _1["href"] }.sort
  end

  test "a product page is found by its SKU" do
    get "/products/cro"
    assert_response :success
    assert_select "h1", "Croissant"
  end

  test "unknown SKUs and old numeric URLs are 404" do
    get "/products/xyz"
    assert_response :not_found
    get "/products/#{products(:croissant).id}"
    assert_response :not_found
  end
end
