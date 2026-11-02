require 'minitest/autorun'
require_relative 'setup'

class DecimalInvoiceLineApiTest < Minitest::Test
  def numericality(attribute)
    InvoiceLine.validators_on(attribute).grep(ActiveModel::Validations::NumericalityValidator).first
  end

  # numericality or comparison both express the lower bound.
  def test_unit_price_has_a_lower_bound_validator
    validators = InvoiceLine.validators_on(:unit_price).grep(ActiveModel::Validations::NumericalityValidator) +
                 InvoiceLine.validators_on(:unit_price).grep(ActiveModel::Validations::ComparisonValidator)
    assert validators.any? { _1.options.key?(:greater_than_or_equal_to) }
  end

  def test_quantity_uses_integer_numericality
    assert numericality(:quantity)&.options&.dig(:only_integer)
  end
end
