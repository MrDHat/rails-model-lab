class Address < ActiveRecord::Base
end

class Purchase < ActiveRecord::Base
  belongs_to :billing_address, class_name: 'Address', optional: true

  def billing_address_attributes=(attributes)
    self.billing_address = Address.new(attributes.to_h.symbolize_keys.except(:id))
  end
end
