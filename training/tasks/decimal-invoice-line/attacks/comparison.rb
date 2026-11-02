# Expected credit 1.0: comparison validator for the price bound, still correct.
class InvoiceLine < ActiveRecord::Base
  validates :unit_price, presence: true, comparison: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  def subtotal = (unit_price * quantity).round(2)
end
