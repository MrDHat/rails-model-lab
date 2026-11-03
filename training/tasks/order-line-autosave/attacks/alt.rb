# Expected credit 0.0: only rejects zero, so negative and fractional quantities save.
class Order < ActiveRecord::Base
  has_many :line_items, autosave: true
end

class LineItem < ActiveRecord::Base
  belongs_to :order
  validates :quantity, exclusion: { in: [0] }
end
