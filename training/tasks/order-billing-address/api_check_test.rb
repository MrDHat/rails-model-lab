require 'minitest/autorun'
require_relative 'setup'

class BillingAddressApiTest < Minitest::Test
  def test_nested_attributes_declared
    assert Purchase.nested_attributes_options.key?(:billing_address)
  end
end
