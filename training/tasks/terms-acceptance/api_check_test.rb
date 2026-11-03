require 'minitest/autorun'
require_relative 'setup'

class TermsAcceptanceApiTest < Minitest::Test
  def test_uses_acceptance_validator
    assert_includes Member.validators_on(:terms_of_service).map(&:kind), :acceptance
  end
end
