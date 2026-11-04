require "test_helper"

class OrderItemsNestedTest < ActionDispatch::IntegrationTest
  setup { @order = orders(:lea_morning) }

  def change(items, order = @order)
    patch api_order_path(order, api_key: api_key), params: { items: items }, as: :json
  end

  def lines(order = @order) = order.reload.order_items.map { [_1.product.sku, _1.quantity] }.sort

  test "changes, removes and adds items and recalculates the total" do
    change([{ id: order_items(:lea_croissants).id, quantity: 5 },
            { id: order_items(:lea_baguette).id, remove: true },
            { sku: "BAG", quantity: 2 }])
    assert_response :success
    assert_equal [["BAG", 2], ["CRO", 5]], lines
    assert_equal 940, @order.reload.total_cents
    assert_equal 940, response.parsed_body["total_cents"]
  end

  test "an invalid entry changes nothing" do
    change([{ id: order_items(:lea_croissants).id, quantity: 5 }, { sku: "BAG", quantity: 0 }])
    assert_response :unprocessable_entity
    assert_equal ["Order items quantity must be greater than 0"], response.parsed_body["errors"]
    assert_equal [["BAG", 1], ["CRO", 2]], lines
    assert_equal 400, @order.reload.total_cents
  end

  test "another order's item is a 404" do
    change([{ id: order_items(:tom_baguette).id, quantity: 9 }])
    assert_response :not_found
    assert_equal 1, order_items(:tom_baguette).reload.quantity
  end

  test "only placed orders change" do
    @order.update!(status: Order::BAKING)
    change([{ id: order_items(:lea_croissants).id, quantity: 5 }])
    assert_response :unprocessable_entity
    assert_equal({ "errors" => ["Order can't be changed once baking has started"] }, response.parsed_body)
    assert_equal [["BAG", 1], ["CRO", 2]], lines
  end

  test "status changes still work" do
    patch api_order_path(@order, api_key: api_key), params: { status: Order::BAKING }, as: :json
    assert_response :success
    assert_equal Order::BAKING, @order.reload.status
  end
end
