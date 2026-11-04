require "test_helper"

class PriceBumpUpdateAllTest < ActiveSupport::TestCase
  test "raises active prices by the percentage in one statement" do
    travel_to Time.utc(2026, 4, 1, 6)
    statements = []
    counter = ->(*, payload) { statements << payload[:sql] if payload[:sql].match?(/\A\s*(UPDATE|INSERT|DELETE)/i) }
    changed = ActiveSupport::Notifications.subscribed(counter, "sql.active_record") { Product.raise_prices!(7) }
    assert_equal 2, changed
    assert_equal 1, statements.size, statements.inspect
    assert_equal [150, 128, 350], [products(:croissant), products(:baguette), products(:eclair)].map { _1.reload.price_cents }
    assert_equal Time.utc(2026, 4, 1, 6), products(:croissant).updated_at
    assert_not_equal Time.utc(2026, 4, 1, 6), products(:eclair).updated_at
  ensure
    travel_back
  end

  test "rounds to the nearest cent" do
    Product.create!(name: "Tart", sku: "TRT", price_cents: 333)
    Product.raise_prices!(2.5)
    assert_equal 341, Product.find_by!(sku: "TRT").price_cents
  end
end
