require 'minitest/autorun'
require_relative 'setup'

# A queue adapter that takes a batch in one call, and records every call.
class BatchAdapter
  attr_reader :batches, :singles

  def initialize = (@batches, @singles = [], [])
  def enqueue(job) = singles << job
  def enqueue_at(job, _at) = singles << job

  def enqueue_all(jobs)
    batches << jobs
    jobs.each { _1.successfully_enqueued = true }
    jobs.size
  end
end

class DigestTest < Minitest::Test
  def setup
    @adapter = BatchAdapter.new
    @previous = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = @adapter
  end

  def teardown
    ActiveJob::Base.queue_adapter = @previous
  end

  def test_one_batch_with_one_job_per_user
    Digest.send_all([3, 5, 8])
    assert_empty @adapter.singles, 'enqueued jobs one at a time'
    assert_equal 1, @adapter.batches.size
    jobs = @adapter.batches.first
    assert_equal [[3], [5], [8]], jobs.map(&:arguments)
    assert(jobs.all? { _1.instance_of?(DigestJob) })
  end
end
