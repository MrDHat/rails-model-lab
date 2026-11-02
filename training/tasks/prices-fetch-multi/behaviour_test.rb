require 'minitest/autorun'
require_relative 'setup'

class PriceListTest < Minitest::Test
  def test_looks_up_only_misses_with_one_read
    cache = ActiveSupport::Cache::MemoryStore.new
    cache.write('B2', 999)
    PriceLookup.looked_up = []
    single_reads = 0
    multi_reads = []
    counter = ->(*) { single_reads += 1 }
    multi = ->(*, payload) { multi_reads << Array(payload[:key]).size }
    prices = ActiveSupport::Notifications.subscribed(multi, 'cache_read_multi.active_support') do
      ActiveSupport::Notifications.subscribed(counter, 'cache_read.active_support') do
        PriceList.prices(%w[A1 B2 C3], cache)
      end
    end
    assert_equal({ 'A1' => 'A1'.sum, 'B2' => 999, 'C3' => 'C3'.sum }, prices)
    assert_equal %w[A1 C3], PriceLookup.looked_up
    assert_equal 'C3'.sum, cache.read('C3')
    assert_equal 0, single_reads
    assert_equal [3], multi_reads, 'expected one read covering all three SKUs'
  end
end
