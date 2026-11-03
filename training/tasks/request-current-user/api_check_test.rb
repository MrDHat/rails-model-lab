require 'minitest/autorun'
require_relative 'setup'

class CurrentUserApiTest < Minitest::Test
  def test_current_attributes
    assert_operator Current, :<, ActiveSupport::CurrentAttributes
  end
end
