require 'minitest/autorun'
require_relative 'setup'

class PriceImportTest < Minitest::Test
  def test_inserts_and_updates_in_one_statement
    Price.delete_all
    Price.create!(sku: 'A', cents: 100)
    writes = 0
    counter = ->(*, payload) { writes += 1 if payload[:sql].match?(/\A\s*(INSERT|UPDATE)/i) }
    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') do
      PriceImport.call([{ sku: 'A', cents: 150 }, { sku: 'B', cents: 200 }])
    end
    assert_equal({ 'A' => 150, 'B' => 200 }, Price.pluck(:sku, :cents).to_h)
    assert_equal 1, writes
  end
end
