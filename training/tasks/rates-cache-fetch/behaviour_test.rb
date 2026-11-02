require 'minitest/autorun'
require_relative 'setup'

class RateCardTest < Minitest::Test
  include ActiveSupport::Testing::TimeHelpers

  def test_cached_for_ten_minutes
    RateCard.cache.clear
    RateSource.calls = 0
    assert_equal({ 'usd' => 1.0 }, RateCard.current)
    travel 9.minutes do
      RateCard.current
      assert_equal 1, RateSource.calls
    end
    travel 11.minutes do
      RateCard.current
      assert_equal 2, RateSource.calls
    end
  end
end
