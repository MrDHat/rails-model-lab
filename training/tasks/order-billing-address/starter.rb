class Address < ActiveRecord::Base
end

class Purchase < ActiveRecord::Base
  belongs_to :billing_address, class_name: 'Address', optional: true
end
