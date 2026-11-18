require "test_helper"

class BriefingBulkEnqueueTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def queued_readers = enqueued_jobs.select { _1["job_class"] == "BriefingDeliveryJob" }.map { _1["arguments"].first["_aj_globalid"] }

  test "a rerun on the same day queues nobody twice" do
    assert_equal 2, MorningBriefing.deliver
    clear_enqueued_jobs
    travel 20.minutes
    assert_equal 0, MorningBriefing.deliver
    assert_empty queued_readers
  end

  test "a rerun queues readers the first run missed" do
    MorningBriefing.deliver
    clear_enqueued_jobs
    kai = Reader.create!(email: "kai@example.com", display_name: "Kai", briefing: true)
    assert_equal 1, MorningBriefing.deliver
    assert_equal [kai.to_global_id.to_s], queued_readers
  end

  test "everyone gets the next day's briefing" do
    MorningBriefing.deliver
    clear_enqueued_jobs
    travel 1.day
    article = Article.create!(section: sections(:news), headline: "Tuesday's news", status: :published, published_at: 1.hour.ago)
    assert_equal 2, MorningBriefing.deliver
    assert_equal [[article.id]], enqueued_jobs.map { _1["arguments"].last }.uniq
  end

  test "thousands of readers are all queued, each once" do
    now = Time.current
    Reader.insert_all(Array.new(2500) do |i|
      { email: "reader#{i}@example.com", display_name: "Reader #{i}", api_token: "bulk-#{i}", briefing: i.even?,
        created_at: now, updated_at: now }
    end)
    assert_equal 1252, MorningBriefing.deliver
    assert_equal 1252, queued_readers.uniq.size
    assert_equal 1252, queued_readers.size
  end
end
