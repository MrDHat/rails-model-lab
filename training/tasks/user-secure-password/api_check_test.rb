require 'minitest/autorun'
require_relative 'setup'

class StaffPasswordApiTest < Minitest::Test
  def test_has_secure_password
    assert Staff.ancestors.any? { _1.is_a?(ActiveModel::SecurePassword::InstanceMethodsOnActivation) }
  end
end
