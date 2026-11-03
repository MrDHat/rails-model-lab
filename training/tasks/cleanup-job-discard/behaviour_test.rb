require 'minitest/autorun'
require_relative 'setup'

class CleanupJobTest < Minitest::Test
  def queue = ActiveJob::Base.queue_adapter.enqueued_jobs

  def setup
    queue.clear
  end

  def test_cleans_existing_upload
    upload = Upload.create!
    CleanupJob.perform_now(upload.id)
    assert upload.reload.cleaned
  end

  def test_missing_upload_is_dropped
    CleanupJob.perform_now(-1)
    assert_empty queue
  end
end
