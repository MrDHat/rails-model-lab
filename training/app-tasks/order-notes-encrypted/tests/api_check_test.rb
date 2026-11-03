require "test_helper"

class OrderNotesEncryptedApiTest < ActiveSupport::TestCase
  test "notes use Active Record encryption" do
    assert_includes Order.encrypted_attributes.to_a, :notes
  end
end
