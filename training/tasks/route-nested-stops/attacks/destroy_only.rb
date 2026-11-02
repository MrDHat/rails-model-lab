# Expected credit 0.1: allows destroy by hand instead of nested attributes.
class DeliveryRoute < ActiveRecord::Base
  has_many :stops, inverse_of: :delivery_route
  accepts_nested_attributes_for :stops, reject_if: proc { |a| a.except('_destroy').values.all?(&:blank?) }, allow_destroy: true
end
class Stop < ActiveRecord::Base
  belongs_to :delivery_route, inverse_of: :stops
  validates :label, presence: true
end
