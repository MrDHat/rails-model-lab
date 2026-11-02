require 'minitest/autorun'
require_relative 'setup'

class DigestTest < Minitest::Test
  def test_one_job_per_user
    queue = ActiveJob::Base.queue_adapter.enqueued_jobs
    queue.clear
    Digest.send_all([3, 5, 8])
    assert_equal [[3], [5], [8]], queue.map { _1[:args] }
    assert(queue.all? { _1[:job] == DigestJob })
  end
end
