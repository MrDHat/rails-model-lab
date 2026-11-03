require 'minitest/autorun'
require_relative 'setup'

class ItemSkuApiTest < Minitest::Test
  def test_sku_is_readonly
    assert_includes Item.readonly_attributes, 'sku'
  end
end
