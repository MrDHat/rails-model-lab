require "test_helper"

class PhoneNumberTest < ActiveSupport::TestCase
  test "formats Brazilian numbers as E.164" do
    assert_equal "+5511987654321", PhoneNumber.e164("(11) 98765-4321")
    assert_equal "+5511987654321", PhoneNumber.e164("+55 11 98765 4321")
    assert_equal "+5511987654321", PhoneNumber.e164("11987654321")
    assert_equal "+551130000001", PhoneNumber.e164("11 3000-0001")
  end

  test "shows numbers the Brazilian way" do
    assert_equal "(11) 98765-4321", PhoneNumber.display("+5511987654321")
    assert_equal "+447700900123", PhoneNumber.display("+447700900123")
  end
end
