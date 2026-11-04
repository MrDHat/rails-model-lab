require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "place! prices the items and totals the order" do
    order = Order.place!(customer: customers(:tom), items: [{ sku: "CRO", quantity: 3 }, { sku: "BAG", quantity: 1 }])
    assert_equal 540, order.total_cents
    assert_equal [140, 120], order.order_items.map(&:unit_price_cents)
  end

  test "place! saves nothing when a product is unknown or inactive" do
    assert_no_difference -> { Order.count } do
      assert_raises(ActiveRecord::RecordNotFound) do
        Order.place!(customer: customers(:tom), items: [{ sku: "CRO", quantity: 1 }, { sku: "ECL", quantity: 1 }])
      end
    end
  end
end
