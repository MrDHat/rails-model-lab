require 'minitest/autorun'
require_relative 'setup'

class StoryViewsTest < Minitest::Test
  # Runs `competitor` once, just after the first query matching `pattern`,
  # as if another server acted between this code's read and its write.
  def with_competitor(pattern, competitor)
    fired = false
    callback = lambda do |*, payload|
      next if fired || !payload[:sql].match?(pattern)
      fired = true
      competitor.call
    end
    result = ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') { yield }
    [result, fired]
  end

  def test_view_recorded_elsewhere_between_read_and_write
    id = Story.create!.id
    story = Story.find(id)
    other_server = -> { Story.connection.execute("UPDATE stories SET views = views + 1 WHERE id = #{id}") }
    _, fired = with_competitor(/\ASELECT .*stories/i, other_server) { story.record_view! }
    assert_equal fired ? 2 : 1, Story.find(id).views
  end
  def test_concurrent_copies_both_count
    id = Story.create!.id
    one = Story.find(id)
    two = Story.find(id)
    one.record_view!
    two.record_view!
    assert_equal 2, Story.find(id).views
  end
end
