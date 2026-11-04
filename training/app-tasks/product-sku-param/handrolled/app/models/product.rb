class Product < ApplicationRecord
  has_many :order_items

  validates :name, :sku, presence: true
  validates :sku, uniqueness: true
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }

  scope :available, -> { where(active: true) }

  def as_api = { sku: sku, name: name, price_cents: price_cents, stock: stock }
end
