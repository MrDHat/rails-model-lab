require 'minitest/autorun'
require_relative 'setup'

class SignupEmailApiTest < Minitest::Test
  def test_uses_format_and_length_validators
    kinds = Signup.validators_on(:email).map(&:kind)
    assert_includes kinds, :format
    assert_includes kinds, :length
  end
end
