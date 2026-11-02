require 'minitest/autorun'
require_relative 'setup'

class SyncJobTest < Minitest::Test
  def queue = ActiveJob::Base.queue_adapter.enqueued_jobs

  def setup
    queue.clear
  end

  def teardown
    Remote.error = nil
  end

  def test_three_attempts_then_raise
    Remote.error = Timeout::Error
    attempts = 1
    SyncJob.perform_now
    retry_job = queue.first
    assert_in_delta Time.now.to_f + 32, retry_job[:at], 3
    assert_raises(Timeout::Error) do
      while (job = queue.shift)
        attempts += 1
        ActiveJob::Base.execute(job)
      end
    end
    assert_equal 3, attempts
  end

  def test_other_errors_raise_without_retry
    Remote.error = ArgumentError
    assert_raises(ArgumentError) { SyncJob.perform_now }
    assert_empty queue
  end
end
