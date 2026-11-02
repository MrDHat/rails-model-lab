require 'minitest/autorun'
require_relative 'setup'

class PostTagsTest < Minitest::Test
  def raw(post)
    Post.connection.select_value("SELECT tags FROM posts WHERE id = #{post.id}")
  end

  def test_array_round_trips_as_json
    post = Post.create!(tags: %w[ruby rails])
    assert_equal %w[ruby rails], Post.find(post.id).tags
    assert_equal %w[ruby rails], JSON.parse(raw(post))
  end

  def test_missing_tags_read_as_empty
    assert_equal [], Post.new.tags
  end
end
