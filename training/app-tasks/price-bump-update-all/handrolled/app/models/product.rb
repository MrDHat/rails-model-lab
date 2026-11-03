class Product < ApplicationRecord
  has_many :order_items

  validates :name, :sku, presence: true
  validates :sku, uniqueness: true
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }

  scope :available, -> { where(active: true) }

  def self.raise_prices!(percent)
    sql = "UPDATE products SET price_cents = ROUND(price_cents * %s), updated_at = %s WHERE active = %s"
    connection.exec_update(format(sql, connection.quote(1 + percent / 100.0), connection.quote(Time.current), connection.quote(true)))
  end

  def as_api = { sku: sku, name: name, price_cents: price_cents, stock: stock }
end
