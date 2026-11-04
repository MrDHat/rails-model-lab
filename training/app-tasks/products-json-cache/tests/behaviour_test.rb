require "test_helper"

class ProductsJsonCacheTest < ActionDispatch::IntegrationTest
  setup { Rails.cache.clear }

  # Fetches the list and returns it with the number of queries that loaded product rows.
  def fetch_products
    loads = 0
    counter = ->(*, payload) { loads += 1 if payload[:sql].match?(/SELECT "products"\.\*/) }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") { get api_products_path(api_key: api_key), as: :json }
    assert_response :success
    [response.parsed_body.to_h { [_1["sku"], _1["price_cents"]] }, loads]
  end

  test "a repeat request doesn't load the products" do
    first, = fetch_products
    assert_equal({ "BAG" => 120, "CRO" => 140 }, first)
    again, loads = fetch_products
    assert_equal first, again
    assert_equal 0, loads
  end

  test "the cache lives in Rails.cache" do
    fetch_products
    Rails.cache.clear
    _, loads = fetch_products
    assert_equal 1, loads
  end

  test "changes show up on the next request" do
    fetch_products
    products(:croissant).update!(price_cents: 150)
    assert_equal({ "BAG" => 120, "CRO" => 150 }, fetch_products.first)
    Product.create!(name: "Brioche", sku: "BRI", price_cents: 300)
    assert_equal %w[BAG BRI CRO], fetch_products.first.keys
    products(:baguette).update!(active: false)
    assert_equal %w[BRI CRO], fetch_products.first.keys
    Product.find_by!(sku: "BRI").destroy
    assert_equal %w[CRO], fetch_products.first.keys
  end

  test "entries expire after 10 minutes" do
    fetch_products
    travel 11.minutes
    assert_equal 1, fetch_products.last
  end
end
