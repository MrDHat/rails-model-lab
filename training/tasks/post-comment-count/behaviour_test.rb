require 'minitest/autorun'
require_relative 'setup'

class CommentCountTest < Minitest::Test
  def test_count_follows_creates_and_destroys
    article = Article.create!
    first = article.comments.create!
    article.comments.create!
    assert_equal 2, article.reload.comments_count
    first.destroy
    assert_equal 1, article.reload.comments_count
  end
end
