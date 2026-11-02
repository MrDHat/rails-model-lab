require 'minitest/autorun'
require_relative 'setup'

class AccountStatesApiTest < Minitest::Test
  def test_both_are_enums
    assert_equal %w[billing_state status], Account.defined_enums.keys.sort
  end
end
