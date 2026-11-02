class InvoiceLine < ActiveRecord::Base
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def subtotal
    (unit_price * quantity).round(2, BigDecimal::ROUND_HALF_UP)
  end
end
