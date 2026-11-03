class Address < ActiveRecord::Base
end

class Purchase < ActiveRecord::Base
  belongs_to :billing_address, class_name: 'Address', optional: true, autosave: true

  def billing_address_attributes=(attributes)
    attributes = attributes.to_h.symbolize_keys.except(:id)
    (billing_address || build_billing_address).assign_attributes(attributes)
  end
end
