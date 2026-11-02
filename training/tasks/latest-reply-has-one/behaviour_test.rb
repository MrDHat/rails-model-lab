require 'minitest/autorun'
require_relative 'setup'

class LatestReplyTest < Minitest::Test
  def setup
    Reply.delete_all
    Discussion.delete_all
    @thread = Discussion.create!(subject: 'Hi')
    @newest = @thread.replies.create!(body: 'newest', posted_at: Time.utc(2026, 3, 1))
    @thread.replies.create!(body: 'imported late', posted_at: Time.utc(2026, 1, 1))
  end

  def test_newest_by_posted_at
    assert_equal @newest.id, @thread.latest_reply.id
  end

  def test_nil_without_replies
    assert_nil Discussion.create!(subject: 'Empty').latest_reply
  end

  def test_can_be_loaded_for_a_list
    threads = Discussion.includes(:latest_reply).to_a
    assert_equal ['newest'], threads.map { _1.latest_reply.body }
  end
end
