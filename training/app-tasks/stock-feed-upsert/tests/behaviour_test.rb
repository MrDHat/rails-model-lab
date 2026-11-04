require "test_helper"

class StockFeedUpsertTest < ActionDispatch::IntegrationTest
  def feed(rows)
    writes = []
    counter = ->(*, payload) { writes << payload[:sql] if payload[:sql].match?(/\A\s*(INSERT|UPDATE|DELETE)/i) }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") do
      post api_stock_path(api_key: api_key), params: { products: rows }, as: :json
    end
    assert_response :success
    writes
  end

  test "updates known products and adds unknown ones as inactive, in one statement" do
    Product.update_all(created_at: 2.days.ago, updated_at: 2.days.ago)
    writes = feed([
      { sku: "CRO", name: "Butter croissant", price_cents: 999, stock: 35 },
      { sku: "ECL", name: "Eclair", price_cents: 1, stock: 12 },
      { sku: "PAC", name: "Pain au chocolat", price_cents: 160, stock: 20 }
    ])
    assert_equal 1, writes.size, writes.inspect
    assert_equal({ "received" => 3 }, response.parsed_body)
    croissant = products(:croissant).reload
    assert_equal ["Croissant", 140, 35, true], [croissant.name, croissant.price_cents, croissant.stock, croissant.active]
    assert_operator croissant.updated_at, :>, 1.hour.ago
    eclair = products(:eclair).reload
    assert_equal ["Éclair", 350, 12, false], [eclair.name, eclair.price_cents, eclair.stock, eclair.active]
    pac = Product.find_by!(sku: "PAC")
    assert_equal ["Pain au chocolat", 160, 20, false], [pac.name, pac.price_cents, pac.stock, pac.active]
    assert_operator pac.created_at, :>, 1.hour.ago
    assert_operator products(:baguette).reload.updated_at, :<, 1.day.ago
  end

  test "a big feed is still one statement" do
    rows = Array.new(300) { { sku: "NEW#{_1}", name: "Loaf #{_1}", price_cents: 300, stock: _1 } }
    assert_equal 1, feed(rows).size
    assert_equal 299, Product.find_by!(sku: "NEW299").stock
    assert_equal({ "received" => 300 }, response.parsed_body)
  end
end
