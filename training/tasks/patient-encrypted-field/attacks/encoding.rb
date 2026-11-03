# Expected credit 0.0: Base64 with a random prefix, which is not encryption.
class Patient < ActiveRecord::Base
  def tax_id=(value)
    self[:tax_id] = value && "#{SecureRandom.hex(8)}:#{Base64.strict_encode64(value)}"
  end
  def tax_id
    value = self[:tax_id]
    value && Base64.strict_decode64(value.split(':', 2).last)
  end
end
