class InvoiceLine < ActiveRecord::Base
  def subtotal
    unit_price.to_f.round(2) * quantity.to_i
  end
end
