require 'minitest/autorun'
require_relative 'setup'

class ShirtSizeApiTest < Minitest::Test
  def test_size_is_an_enum
    assert_equal({ 'small' => 's', 'medium' => 'm', 'large' => 'l' }, Shirt.defined_enums['size'])
  end
end
