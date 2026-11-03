require 'minitest/autorun'
require_relative 'setup'

class ResetTokenApiTest < Minitest::Test
  def test_token_definition
    assert Account.token_definitions.key?(:password_reset)
  end
end
