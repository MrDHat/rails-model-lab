require "test_helper"

class OrderItemsNestedApiTest < ActiveSupport::TestCase
  test "orders accept nested attributes for their items" do
    assert Order.nested_attributes_options.key?(:order_items), "no accepts_nested_attributes_for :order_items"
  end
end
