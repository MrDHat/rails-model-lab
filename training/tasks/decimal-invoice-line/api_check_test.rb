require 'minitest/autorun'
require_relative 'setup'

class DecimalInvoiceLineApiTest < Minitest::Test
  def numericality(attribute)
    InvoiceLine.validators_on(attribute).grep(ActiveModel::Validations::NumericalityValidator).first
  end

  def test_unit_price_uses_numericality
    assert numericality(:unit_price)&.options&.key?(:greater_than_or_equal_to)
  end

  def test_quantity_uses_integer_numericality
    assert numericality(:quantity)&.options&.dig(:only_integer)
  end
end
