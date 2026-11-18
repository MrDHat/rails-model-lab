require "test_helper"

class ArticleSlugsTest < ActionDispatch::IntegrationTest
  def create(headline) = Article.create!(section: sections(:news), headline: headline)

  test "slugs are plain ASCII words joined by hyphens" do
    assert_equal "cafe-owners-say-no-to-new-rules", create(%(Café owners say "no" to new rules!)).slug
    assert_equal "maori-ward-vote-what-happens-next", create("Māori ward vote: what happens next?").slug
    assert_equal "2-000-turn-out-for-the-harbour-swim", create("  2,000 turn out -- for the harbour swim ").slug
  end

  test "taken slugs get a number" do
    assert_equal "harbour-bridge-tolls-to-rise-2", create("Harbour Bridge tolls to rise").slug
    assert_equal "harbour-bridge-tolls-to-rise-3", create("Harbour Bridge: tolls to rise").slug
    assert_equal "ferry-crews-vote-on-strike-2", create("Ferry crews vote on strike").slug
  end

  test "editing the headline keeps the slug" do
    article = create("Ferry fares frozen")
    article.update!(headline: "Ferry fares frozen until June")
    assert_equal "ferry-fares-frozen", article.reload.slug
  end

  test "stories written in the newsroom get them too" do
    sign_in_editor editors(:owen)
    post newsroom_articles_path, params: { article: { headline: "Ōtaki café wins award", section_id: sections(:news).id,
                                                      author_ids: [authors(:eli).id] } }
    assert_redirected_to edit_newsroom_article_path("otaki-cafe-wins-award")
  end
end
