require 'minitest/autorun'
require_relative 'setup'

class ExportTest < Minitest::Test
  def test_exports_everything_in_bounded_batches
    Subscriber.delete_all
    Subscriber.insert_all(Array.new(1_201) { { email: "u#{_1}@example.com" } })
    largest = 0
    counter = ->(*, payload) { largest = [largest, payload[:record_count].to_i].max if payload[:class_name] == 'Subscriber' }
    io = StringIO.new
    ActiveSupport::Notifications.subscribed(counter, 'instantiation.active_record') { SubscriberExport.call(io) }
    lines = io.string.lines(chomp: true)
    assert_equal 1_201, lines.size
    assert_equal 'u0@example.com', lines.first
    assert_equal 'u1200@example.com', lines.last
    assert_operator largest, :<=, 500
  end
end
