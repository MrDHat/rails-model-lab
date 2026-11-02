class Order < ActiveRecord::Base
  has_many :line_items
  validate :line_items_valid
  after_save :save_changed_line_items

  private

  def line_items_valid
    errors.add(:line_items, :invalid) if line_items.any? { _1.changed? && _1.invalid? }
  end

  def save_changed_line_items
    line_items.each { _1.save! if _1.changed? }
  end
end

class LineItem < ActiveRecord::Base
  belongs_to :order
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end
