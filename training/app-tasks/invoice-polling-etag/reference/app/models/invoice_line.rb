class InvoiceLine < ApplicationRecord
  belongs_to :invoice, touch: true

  validates :description, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price_cents, numericality: { only_integer: true }

  def amount_cents = quantity * unit_price_cents
end
