require 'minitest/autorun'
require_relative 'setup'

class PatientTaxIdApiTest < Minitest::Test
  def test_encrypts_is_declared
    assert_includes Patient.encrypted_attributes, :tax_id
  end
end
