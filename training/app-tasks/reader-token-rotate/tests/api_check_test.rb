require "test_helper"

class ReaderTokenRotateApiTest < ActiveSupport::TestCase
  test "tokens come from has_secure_token" do
    assert_respond_to Reader.new, :regenerate_api_token
    assert Reader.create!(email: "kai@example.com", display_name: "Kai").api_token.present?
  end
end
