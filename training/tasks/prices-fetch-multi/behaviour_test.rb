require 'minitest/autorun'
require_relative 'setup'

class PriceListTest < Minitest::Test
  def test_looks_up_only_misses_with_one_read
    cache = ActiveSupport::Cache::MemoryStore.new
    cache.write('B2', 999)
    PriceLookup.looked_up = []
    single_reads = 0
    counter = ->(*) { single_reads += 1 }
    prices = ActiveSupport::Notifications.subscribed(counter, 'cache_read.active_support') do
      PriceList.prices(%w[A1 B2 C3], cache)
    end
    assert_equal({ 'A1' => 'A1'.sum, 'B2' => 999, 'C3' => 'C3'.sum }, prices)
    assert_equal %w[A1 C3], PriceLookup.looked_up
    assert_equal 'C3'.sum, cache.read('C3')
    assert_equal 0, single_reads
  end
end
