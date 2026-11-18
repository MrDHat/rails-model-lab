require "test_helper"

class MorningBriefingTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "top stories are the most read of the last day" do
    assert_equal [articles(:rugby_final), articles(:council_budget), articles(:harbour_bridge)],
                 MorningBriefing.new.top_stories.to_a
  end

  test "the briefing size setting limits the stories" do
    Setting[:briefing_size] = 2
    assert_equal 2, MorningBriefing.new.top_stories.size
  end

  test "queues a delivery for each reader who opted in" do
    assert_enqueued_jobs 2, only: BriefingDeliveryJob do
      assert_equal 2, MorningBriefing.deliver
    end
    enqueued = enqueued_jobs.map { _1["arguments"].first["_aj_globalid"] }
    assert_equal [readers(:mere), readers(:sam)].map { _1.to_global_id.to_s }.sort, enqueued.sort
  end

  test "nothing to send on a quiet day" do
    travel 3.days
    assert_no_enqueued_jobs { assert_equal 0, MorningBriefing.deliver }
  end
end
