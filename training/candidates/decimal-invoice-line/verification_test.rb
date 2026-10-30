require 'active_record'
require 'active_support/all'
require 'minitest/autorun'
require 'bigdecimal'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :invoice_lines do |t|
    t.decimal :unit_price, precision: 18, scale: 4
    t.integer :quantity
  end
end

implementation = ENV.fetch('CANDIDATE_IMPLEMENTATION', 'reference.rb')
require File.expand_path(implementation, __dir__)

class DecimalInvoiceLineTest < Minitest::Test
  def test_decimal_type_and_exact_multiplication
    row = InvoiceLine.new(unit_price: '0.1', quantity: 3)
    assert row.valid?
    assert_instance_of BigDecimal, row.subtotal
    assert_equal BigDecimal('0.30'), row.subtotal
  end

  def test_rounds_final_total_half_up
    row = InvoiceLine.new(unit_price: '0.335', quantity: 3)
    assert_equal BigDecimal('1.01'), row.subtotal
    assert_equal BigDecimal('0.335'), row.unit_price
  end

  def test_four_decimal_places_survive_persistence
    row = InvoiceLine.create!(unit_price: '12.3456', quantity: 2).reload
    assert_equal BigDecimal('12.3456'), row.unit_price
    assert_equal BigDecimal('24.69'), row.subtotal
  end

  def test_zero_price_is_allowed_but_negative_price_is_not
    assert InvoiceLine.new(unit_price: '0', quantity: 1).valid?
    refute InvoiceLine.new(unit_price: '-0.01', quantity: 1).valid?
  end

  def test_rejects_missing_values
    refute InvoiceLine.new(unit_price: '', quantity: 1).valid?
    refute InvoiceLine.new(unit_price: '1', quantity: nil).valid?
  end

  def test_rejects_zero_negative_and_fractional_quantities
    [0, -1, '1.5'].each do |value|
      row = InvoiceLine.new(unit_price: '1', quantity: value)
      refute row.valid?, "accepted quantity #{value.inspect}"
      assert row.errors[:quantity].any?
    end
  end
end
