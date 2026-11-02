require 'minitest/autorun'
require_relative 'setup'

class ReportQueueTest < Minitest::Test
  def test_queue_follows_plan
    queue = ActiveJob::Base.queue_adapter.enqueued_jobs
    queue.clear
    ReportJob.perform_later(1, 'enterprise')
    ReportJob.perform_later(2, 'starter')
    assert_equal %w[priority default], queue.map { _1[:queue] }
  end
end
