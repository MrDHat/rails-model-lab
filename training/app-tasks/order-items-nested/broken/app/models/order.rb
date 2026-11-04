class Order < ApplicationRecord
  PLACED = 0
  BAKING = 1
  READY = 2
  COLLECTED = 3
  CANCELLED = 4

  belongs_to :customer
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items

  before_save { self.total_cents = order_items.reject(&:marked_for_destruction?).sum { _1.quantity.to_i * _1.unit_price_cents } }

  validates :placed_at, presence: true

  # items: [{ sku:, quantity: }]
  def self.place!(customer:, items:, pickup_at: nil, notes: nil)
    transaction do
      order = create!(customer: customer, placed_at: Time.current, pickup_at: pickup_at, notes: notes)
      items.each do |item|
        product = Product.available.find_by!(sku: item.fetch(:sku))
        order.order_items.create!(product: product, quantity: Integer(item.fetch(:quantity)), unit_price_cents: product.price_cents)
      end
      order.update!(total_cents: order.order_items.sum { _1.quantity * _1.unit_price_cents })
      order
    end
  end

  def ready? = status == READY

  def as_api
    { id: id, status: status, placed_at: placed_at.iso8601, total_cents: total_cents, customer_email: customer.email,
      items: order_items.map { { sku: _1.product.sku, quantity: _1.quantity, unit_price_cents: _1.unit_price_cents } } }
  end
end
