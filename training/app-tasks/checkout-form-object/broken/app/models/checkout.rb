# The API's order request, checked as a whole before an order is placed.
class Checkout
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :customer_email, :string
  attribute :items, default: -> { [] }
  attribute :pickup_at, :string
  attribute :notes, :string

  validates :customer_email, :items, presence: true
  validate :customer_exists, :products_available, :quantities_in_range, :pickup_time_valid, if: -> { errors.none? }

  attr_reader :order

  def save
    return false unless valid?

    @order = Order.place!(customer: customer, items: items.map { { sku: _1[:sku], quantity: _1[:quantity] } },
                          pickup_at: pickup_time, notes: notes)
  end

  private

  def customer = @customer ||= Customer.find_by(email: customer_email)

  def pickup_time = pickup_at.presence && (Time.zone.iso8601(pickup_at) rescue nil)

  def customer_exists
    errors.add(:customer_email, "is not a customer") if customer_email.present? && !customer
  end

  def products_available
    skus = items.map { _1[:sku].to_s }
    (skus - Product.available.where(sku: skus).pluck(:sku)).uniq.each { errors.add(:items, "has an unknown product: #{_1}") }
  end

  def quantities_in_range
    return if items.all? { Integer(_1[:quantity].to_s, exception: false)&.between?(1, 20) }

    errors.add(:items, "has a quantity outside 1 to 20")
  end

  def pickup_time_valid
    errors.add(:pickup_at, "is not a valid time") if pickup_at.present? && !pickup_time
  end
end
