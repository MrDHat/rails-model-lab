require 'minitest/autorun'
require_relative 'setup'

class ItemSkuTest < Minitest::Test
  def test_sku_is_set_on_create_and_kept
    item = Item.create!(sku: 'A-1', name: 'Bolt')
    begin
      item.update(sku: 'B-2')
    rescue StandardError
      nil
    end
    assert_equal 'A-1', Item.find(item.id).sku
  end

  def test_other_columns_stay_editable
    item = Item.create!(sku: 'A-1', name: 'Bolt')
    item.update!(name: 'Nut')
    assert_equal 'Nut', Item.find(item.id).name
  end
end
