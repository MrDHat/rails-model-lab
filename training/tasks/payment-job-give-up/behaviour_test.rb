require 'minitest/autorun'
require_relative 'setup'

class SettleJobTest < Minitest::Test
  def queue = ActiveJob::Base.queue_adapter.enqueued_jobs

  def setup
    queue.clear
    FailureLog.entries.clear
  end

  def run_to_end(id)
    while (job = queue.shift)
      ActiveJob::Base.execute(job)
    end
  rescue GatewayDown
    nil
  end

  def test_logs_after_retries_run_out
    SettleJob.perform_now(7)
    SettleJob.perform_now(-7)
    assert_empty FailureLog.entries, 'logged while a retry was still pending'
    refute_empty queue
    run_to_end(-7)
    assert_equal [[-7, 'GatewayDown']], FailureLog.entries
  end

  def test_logs_discarded_job
    SettleJob.perform_now(0)
    assert_equal [[0, 'ArgumentError']], FailureLog.entries
  end
end
