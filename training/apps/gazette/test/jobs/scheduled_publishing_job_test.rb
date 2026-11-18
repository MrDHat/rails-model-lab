require "test_helper"

class ScheduledPublishingJobTest < ActiveJob::TestCase
  test "publishes ready stories whose time has come, at their scheduled time" do
    ScheduledPublishingJob.perform_now
    assert articles(:night_market).reload.ready?

    travel_to Time.utc(2026, 9, 14, 6, 1)
    ScheduledPublishingJob.perform_now
    article = articles(:night_market).reload
    assert article.published?
    assert_equal Time.utc(2026, 9, 14, 6), article.published_at
    assert_nil article.publish_at
  end

  test "stories without a byline wait" do
    articles(:night_market).authorships.delete_all
    ScheduledPublishingJob.perform_now(1.day.from_now)
    assert articles(:night_market).reload.ready?
  end
end
