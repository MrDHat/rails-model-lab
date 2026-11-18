require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "keeps the story's comment count" do
    article = articles(:council_budget)
    comment = Comment.create!(article: article, reader: readers(:lou), body: "Good news for the library.")
    assert_equal 1, article.reload.comments_count
    comment.destroy
    assert_equal 0, article.reload.comments_count
  end

  test "rejects banned words" do
    comment = Comment.new(article: articles(:council_budget), reader: readers(:lou), body: "This budget is a scam")
    assert_not comment.valid?
    assert_includes comment.errors[:body], "contains words we don't publish"
  end

  test "allows words that only contain a banned word" do
    comment = Comment.new(article: articles(:council_budget), reader: readers(:lou), body: "Scampi at the night market")
    assert comment.valid?
  end

  test "only live stories with comments open take comments" do
    assert_not Comment.new(article: articles(:ferry_strike), reader: readers(:lou), body: "Hi").valid?
    articles(:council_budget).update!(comments_enabled: false)
    comment = Comment.new(article: articles(:council_budget), reader: readers(:lou), body: "Hi")
    assert_not comment.valid?
    assert_includes comment.errors[:base], "Comments are closed on this story."
  end

  test "new comments are pending" do
    comment = Comment.create!(article: articles(:council_budget), reader: readers(:lou), body: "Hi")
    assert comment.pending?
  end
end
