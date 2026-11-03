require 'minitest/autorun'
require_relative 'setup'

class ExportTest < Minitest::Test
  def test_exports_everything_in_bounded_batches
    Subscriber.delete_all
    Subscriber.insert_all(Array.new(1_201) { { email: "u#{_1}@example.com" } })
    largest = 0
    counter = ->(*, payload) { largest = [largest, payload[:row_count].to_i].max }
    io = StringIO.new
    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') { SubscriberExport.call(io) }
    assert_equal Array.new(1_201) { "u#{_1}@example.com" }, io.string.lines(chomp: true)
    assert_operator largest, :<=, 500
  end
end
