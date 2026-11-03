require 'minitest/autorun'
require_relative 'setup'

class LatestReplyApiTest < Minitest::Test
  def test_has_one_association
    assert_equal :has_one, Discussion.reflect_on_association(:latest_reply)&.macro
  end
end
