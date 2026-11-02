require 'minitest/autorun'
require_relative 'setup'

class OrderAutosaveTest < Minitest::Test
  def setup
    LineItem.delete_all
    Order.delete_all
    @order = Order.create!(reference: 'A1')
    @order.line_items.create!(quantity: 1)
    @order.line_items.create!(quantity: 2)
    @order = Order.find(@order.id)
  end

  def test_changed_children_are_saved
    @order.line_items.to_a.first.quantity = 5
    assert @order.save
    assert_equal [5, 2], LineItem.order(:id).pluck(:quantity)
  end

  def test_invalid_child_blocks_the_save
    @order.reference = 'A2'
    @order.line_items.to_a.first.quantity = 0
    refute @order.save
    assert @order.errors.any?
    assert_equal 'A1', Order.find(@order.id).reference
    assert_equal [1, 2], LineItem.order(:id).pluck(:quantity)
  end
end
