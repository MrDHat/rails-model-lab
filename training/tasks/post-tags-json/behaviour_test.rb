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
    post = Post.create!(tags: [])
    assert_equal [], Post.find(post.id).tags
    assert_includes [nil, '[]'], raw(post)
  end

  def test_null_column_reads_as_empty
    Post.connection.execute('INSERT INTO posts (tags) VALUES (NULL)')
    assert_equal [], Post.order(:id).last.tags
  end

  def test_reassigned_tags_are_saved
    post = Post.create!(tags: %w[ruby])
    post.update!(tags: %w[go])
    assert_equal ['go'], JSON.parse(raw(post))
  end
end
