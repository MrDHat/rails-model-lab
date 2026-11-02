require 'minitest/autorun'
require_relative 'setup'

class PageLockApiTest < Minitest::Test
  def test_locking_column
    assert Page.locking_enabled?
    assert_equal 'revision', Page.locking_column
  end
end
