class DeliveryRoute < ActiveRecord::Base
  has_many :stops, inverse_of: :delivery_route
  accepts_nested_attributes_for :stops, reject_if: :all_blank, allow_destroy: true
end

class Stop < ActiveRecord::Base
  belongs_to :delivery_route, inverse_of: :stops
  validates :label, presence: true
end
