class InvoiceLine < ActiveRecord::Base
  validate :price_and_quantity_are_sane

  def subtotal
    (unit_price * quantity).round(2, BigDecimal::ROUND_HALF_UP)
  end

  private

  def price_and_quantity_are_sane
    errors.add(:unit_price, :invalid) if unit_price.nil? || unit_price.negative?
    unless quantity_before_type_cast.to_s.match?(/\A\d+\z/) && quantity.positive?
      errors.add(:quantity, :invalid)
    end
  end
end
