require 'minitest/autorun'
require_relative 'setup'

# `validate: true` makes the enum type itself accept unknown values.
class PaymentStatusApiTest < Minitest::Test
  def test_enum_validates_instead_of_raising
    Payment.type_for_attribute(:status).assert_valid_value('unexpected')
    assert Payment.validators_on(:status).grep(ActiveModel::Validations::InclusionValidator).any?
  end
end
