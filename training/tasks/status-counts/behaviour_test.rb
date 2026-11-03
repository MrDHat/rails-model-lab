require 'minitest/autorun'
require_relative 'setup'

class StatusCountsTest < Minitest::Test
  def test_counts_without_loading_records
    Job.delete_all
    %w[queued queued failed done].each { Job.create!(status: _1) }
    loaded = 0
    counter = ->(*, payload) { loaded += payload[:record_count].to_i }
    counts = ActiveSupport::Notifications.subscribed(counter, 'instantiation.active_record') { Job.status_counts }
    assert_equal({ 'queued' => 2, 'failed' => 1, 'done' => 1 }, counts)
    assert_equal 0, loaded
  end
end
