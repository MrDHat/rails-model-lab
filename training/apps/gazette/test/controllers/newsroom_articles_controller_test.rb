require "test_helper"

class NewsroomArticlesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_editor editors(:owen) }

  test "story list filters" do
    get newsroom_articles_path(status: "draft")
    assert_select "tr", 2
    get newsroom_articles_path(q: "Hawks")
    assert_select "tr", 1
  end

  test "new stories carry the editor's byline" do
    get new_newsroom_article_path
    assert_select "select[name='article[author_ids][]'] option[selected]", "Eli Moana"
  end

  test "creating a draft" do
    post newsroom_articles_path, params: { article: { headline: "Ferry fares frozen", section_id: sections(:news).id,
                                                      body: "Fares stay the same.", tag_list: "transport",
                                                      author_ids: [authors(:hana).id, authors(:eli).id] } }
    article = Article.last
    assert_redirected_to edit_newsroom_article_path(article)
    assert article.draft?
    assert_equal [authors(:hana), authors(:eli)], article.authorships.order(:position).map(&:author)
  end

  test "invalid drafts show the form again" do
    post newsroom_articles_path, params: { article: { headline: "", section_id: sections(:news).id } }
    assert_response :unprocessable_entity
  end

  test "editing" do
    patch newsroom_article_path(articles(:ferry_strike)), params: { article: { dek: "A 24-hour stoppage.", status: "ready" } }
    assert_redirected_to edit_newsroom_article_path(articles(:ferry_strike))
    assert_equal ["A 24-hour stoppage.", "ready"], articles(:ferry_strike).reload.then { [_1.dek, _1.status] }
  end

  test "the desk app edits with JSON" do
    patch newsroom_article_path(articles(:ferry_strike)), params: { article: { headline: "" } }, as: :json
    assert_response :unprocessable_entity
    assert_equal ["Headline can't be blank"], response.parsed_body["errors"]

    patch newsroom_article_path(articles(:ferry_strike)), params: { article: { status: "ready" } }, as: :json
    assert_response :success
    assert_equal "ready", response.parsed_body["status"]
  end

  test "publishing, scheduling, unpublishing and spiking" do
    patch transition_newsroom_article_path(articles(:ferry_strike), event: "publish")
    assert articles(:ferry_strike).reload.published?
    patch transition_newsroom_article_path(articles(:ferry_strike), event: "unpublish")
    patch transition_newsroom_article_path(articles(:ferry_strike), event: "schedule", publish_at: "2026-09-15T07:00")
    assert_equal Time.utc(2026, 9, 14, 19), articles(:ferry_strike).reload.publish_at
    patch transition_newsroom_article_path(articles(:ferry_strike), event: "spike")
    assert articles(:ferry_strike).reload.spiked?
  end

  test "transitions that aren't allowed come back with a message" do
    patch transition_newsroom_article_path(articles(:old_rumour), event: "publish")
    assert_redirected_to newsroom_root_path
    assert_equal "Spiked stories can't be published.", flash[:alert]
  end

  test "adding a correction" do
    post newsroom_article_corrections_path(articles(:harbour_bridge)), params: { correction: { body: "The vote was 9 to 4." } }
    assert_equal editors(:owen), articles(:harbour_bridge).corrections.last.editor
  end
end
