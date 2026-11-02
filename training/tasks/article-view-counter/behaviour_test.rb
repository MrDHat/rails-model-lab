require 'minitest/autorun'
require_relative 'setup'

class StoryViewsTest < Minitest::Test
  def test_concurrent_copies_both_count
    id = Story.create!.id
    one = Story.find(id)
    two = Story.find(id)
    one.record_view!
    two.record_view!
    assert_equal 2, Story.find(id).views
  end
end
