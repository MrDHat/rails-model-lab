# Brazilian phone numbers. Patients type them every which way: "(11)
# 98765-4321", "11 98765 4321", "+55 11 98765-4321". The SMS provider wants
# E.164: "+5511987654321".
module PhoneNumber
  def self.e164(raw)
    return if raw.nil?

    digits = raw.to_s.gsub(/\D/, "")
    digits = digits.delete_prefix("0") if digits.length == 11 && digits.start_with?("0")
    digits = "55#{digits}" if digits.length.between?(10, 11)
    digits.empty? ? "" : "+#{digits}"
  end

  # "+5511987654321" -> "(11) 98765-4321"
  def self.display(e164)
    digits = e164.to_s.delete_prefix("+55")
    return e164.to_s unless digits.match?(/\A\d{10,11}\z/)

    "(#{digits[0, 2]}) #{digits[2..-5]}-#{digits[-4..]}"
  end
end
