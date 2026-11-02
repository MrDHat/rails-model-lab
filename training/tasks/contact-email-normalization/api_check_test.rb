require 'minitest/autorun'
require_relative 'setup'

class ContactEmailApiTest < Minitest::Test
  def test_email_normalization_is_declared
    assert_includes Contact.normalized_attributes, :email
  end
end
