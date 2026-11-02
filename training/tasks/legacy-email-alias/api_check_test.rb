require 'minitest/autorun'
require_relative 'setup'

class LegacyEmailApiTest < Minitest::Test
  def test_alias_is_declared
    assert_equal 'emailaddr', Customer.attribute_aliases['email']
  end
end
