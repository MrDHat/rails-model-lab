require "test_helper"

class ArticleViewCountTest < ActionDispatch::IntegrationTest
  test "views recorded from stale copies all count" do
    first = Article.find(articles(:harbour_bridge).id)
    second = Article.find(articles(:harbour_bridge).id)
    first.record_view!
    second.record_view!
    second.record_view!
    assert_equal 123, articles(:harbour_bridge).reload.views_count
  end

  test "counting doesn't change the story" do
    before = articles(:harbour_bridge).updated_at
    travel 1.minute
    Article.find(articles(:harbour_bridge).id).record_view!
    assert_equal before, articles(:harbour_bridge).reload.updated_at
  end

  test "repeat visits still get a 304 and still count" do
    get article_path(articles(:rugby_final))
    etag = response.headers["ETag"]
    travel 1.minute
    get article_path(articles(:rugby_final)), headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_equal 512, articles(:rugby_final).reload.views_count
  end
end
