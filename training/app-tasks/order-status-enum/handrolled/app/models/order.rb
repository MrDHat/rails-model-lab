class Order < ApplicationRecord
  STATUSES = %w[placed baking ready collected cancelled].freeze
  PLACED, BAKING, READY, COLLECTED, CANCELLED = STATUSES.each_index.to_a

  belongs_to :customer
  has_many :order_items, dependent: :destroy

  validates :placed_at, presence: true
  validates :status, inclusion: { in: STATUSES.each_index.to_a }

  STATUSES.each_with_index do |name, value|
    scope name, -> { where(status: value) }
    define_method(:"#{name}?") { status == value }
  end

  def self.status_value(status) = STATUSES.index(status.to_s) || (status.is_a?(Integer) ? status : nil)

  def status_name = STATUSES[status]

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

  def as_api
    { id: id, status: status_name, placed_at: placed_at.iso8601, total_cents: total_cents, customer_email: customer.email,
      items: order_items.map { { sku: _1.product.sku, quantity: _1.quantity, unit_price_cents: _1.unit_price_cents } } }
  end
end
