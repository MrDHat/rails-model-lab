# Expected credit 1.0: odd accessors, but the column still goes through encryption.
class Patient < ActiveRecord::Base
  encrypts :tax_id
  def tax_id=(value)
    self[:tax_id] = value && "#{SecureRandom.hex(8)}:#{Base64.strict_encode64(value)}"
  end
  def tax_id
    value = self[:tax_id]
    value && Base64.strict_decode64(value.split(':', 2).last)
  end
end
