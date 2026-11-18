require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "shows a live story with its approved comments and corrections" do
    get article_path(articles(:harbour_bridge))
    assert_response :success
    assert_select "h1", "Harbour Bridge tolls to rise in March"
    assert_select ".comment", 1
    assert_select ".comment", text: /Another tax/, count: 0

    get article_path(articles(:council_budget))
    assert_select ".corrections", /rates would rise 8 per cent/
  end

  test "counts a view per reader visit" do
    assert_difference -> { articles(:harbour_bridge).reload.views_count }, 1 do
      get article_path(articles(:harbour_bridge))
    end
  end

  test "drafts, spiked and scheduled stories are not found" do
    get article_path(articles(:ferry_strike))
    assert_response :not_found
    get article_path(articles(:night_market))
    assert_response :not_found
  end

  test "editors can preview drafts, and their visits don't count" do
    sign_in_editor editors(:owen)
    assert_no_difference -> { articles(:ferry_strike).reload.views_count } do
      get article_path(articles(:ferry_strike))
    end
    assert_response :success
    assert_select ".preview", /draft/
    assert_select "a", "Edit"
  end

  test "repeat visits get a 304" do
    get article_path(articles(:rugby_final))
    etag = response.headers["ETag"]
    get article_path(articles(:rugby_final)), headers: { "If-None-Match" => etag }
    assert_response :not_modified
  end

  test "a newly approved comment changes the page" do
    get article_path(articles(:harbour_bridge))
    etag = response.headers["ETag"]
    travel 1.minute
    comments(:harbour_sam).approved!
    get article_path(articles(:harbour_bridge)), headers: { "If-None-Match" => etag }
    assert_response :success
    assert_select ".comment", 2
  end
end
