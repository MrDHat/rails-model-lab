require "test_helper"

class ArticleStatusValidateTest < ActionDispatch::IntegrationTest
  setup { sign_in_editor editors(:owen) }

  test "the form comes back with a message" do
    patch newsroom_article_path(articles(:ferry_strike)), params: { article: { status: "killed", dek: "New dek" } }
    assert_response :unprocessable_entity
    assert_select ".errors li", "Status is not included in the list"
    article = articles(:ferry_strike).reload
    assert_equal ["draft", nil], [article.status, article.dek]
  end

  test "the desk app gets a 422" do
    patch newsroom_article_path(articles(:ferry_strike)), params: { article: { status: "live" } }, as: :json
    assert_response :unprocessable_entity
    assert_equal ["Status is not included in the list"], response.parsed_body["errors"]
    assert articles(:ferry_strike).reload.draft?
  end

  test "known statuses still save" do
    patch newsroom_article_path(articles(:ferry_strike)), params: { article: { status: "ready" } }, as: :json
    assert_response :success
    assert articles(:ferry_strike).reload.ready?
  end
end
