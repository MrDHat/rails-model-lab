require "test_helper"

class ArticleCdnCacheTest < ActionDispatch::IntegrationTest
  def cache_control = response.headers["Cache-Control"].to_s.split(",").map(&:strip)

  test "readers' story pages can be cached publicly for five minutes" do
    get article_path(articles(:harbour_bridge))
    assert_response :success
    assert_includes cache_control, "public"
    assert_includes cache_control, "max-age=300"
    assert_not_includes cache_control, "private"
  end

  test "repeat visits still get a 304 that can be cached too" do
    get article_path(articles(:rugby_final))
    get article_path(articles(:rugby_final)), headers: { "If-None-Match" => response.headers["ETag"] }
    assert_response :not_modified
    assert_includes cache_control, "public"
    assert_includes cache_control, "max-age=300"
  end

  test "editors' pages stay out of shared caches" do
    sign_in_editor editors(:owen)
    get article_path(articles(:harbour_bridge))
    assert_response :success
    assert_not_includes cache_control, "public"
    assert (cache_control & %w[private no-store]).any?, "Cache-Control was #{cache_control.inspect}"

    get article_path(articles(:ferry_strike))
    assert_response :success
    assert_not_includes cache_control, "public"
    assert (cache_control & %w[private no-store]).any?, "Cache-Control was #{cache_control.inspect}"
  end
end
