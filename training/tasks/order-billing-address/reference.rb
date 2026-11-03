class Address < ActiveRecord::Base
end

class Purchase < ActiveRecord::Base
  belongs_to :billing_address, class_name: 'Address', optional: true
  accepts_nested_attributes_for :billing_address
end
