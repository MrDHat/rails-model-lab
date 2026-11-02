class DeliveryRoute < ActiveRecord::Base
  has_many :stops, inverse_of: :delivery_route
  accepts_nested_attributes_for :stops, allow_destroy: true,
    reject_if: ->(row) { row.except('_destroy', :_destroy).values.all?(&:blank?) }
end

class Stop < ActiveRecord::Base
  belongs_to :delivery_route, inverse_of: :stops
  validates :label, presence: true
end
