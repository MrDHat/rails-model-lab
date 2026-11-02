class Order < ActiveRecord::Base
  has_many :line_items, autosave: true
end

class LineItem < ActiveRecord::Base
  belongs_to :order
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end
