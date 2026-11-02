# Expected credit 0.0: Float maths, which rounds 1.005 * 3 down.
class InvoiceLine < ActiveRecord::Base
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  def subtotal = BigDecimal((unit_price.to_f * quantity).round(2).to_s)
end
