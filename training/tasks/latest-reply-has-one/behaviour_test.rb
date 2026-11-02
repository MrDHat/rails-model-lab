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

  def test_list_loads_in_fixed_queries
    5.times { |i| Discussion.create!(subject: "T#{i}").replies.create!(body: "r#{i}", posted_at: Time.utc(2026, 2, 1)) }
    queries = 0
    counter = ->(*, payload) { queries += 1 unless payload[:name] == 'SCHEMA' }
    bodies = ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') do
      Discussion.with_latest_reply.to_a.map { _1.latest_reply.body }
    end
    assert_equal ['newest', 'r0', 'r1', 'r2', 'r3', 'r4'], bodies.sort
    assert_operator queries, :<=, 3
  end
end
