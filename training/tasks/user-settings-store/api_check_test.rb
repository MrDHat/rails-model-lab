require 'minitest/autorun'
require_relative 'setup'

class UserSettingsApiTest < Minitest::Test
  def test_store_accessors_are_declared
    assert_equal %i[theme digest].sort, Array(User.stored_attributes[:settings]).sort
  end
end
