require "test_helper"

class ProductSkuParamApiTest < ActiveSupport::TestCase
  test "the product's URL parameter is its SKU" do
    assert_equal "bag", products(:baguette).to_param
  end
end
