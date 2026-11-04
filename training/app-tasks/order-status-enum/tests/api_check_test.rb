require "test_helper"

class OrderStatusEnumApiTest < ActiveSupport::TestCase
  test "status is an Active Record enum" do
    assert_equal({ "placed" => 0, "baking" => 1, "ready" => 2, "collected" => 3, "cancelled" => 4 }, Order.defined_enums["status"])
  end
end
