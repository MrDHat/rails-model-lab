class Patient < ActiveRecord::Base
  def tax_id
    self[:tax_id] && Base64.strict_decode64(self[:tax_id])
  end

  def tax_id=(value)
    self[:tax_id] = value && Base64.strict_encode64(value)
  end
end
