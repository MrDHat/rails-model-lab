require "test_helper"

class RelatedStoriesTest < ActionDispatch::IntegrationTest
  def story(headline, tags, published_at)
    article = Article.create!(section: sections(:news), headline: headline, tag_list: tags, status: :published,
                              published_at: published_at)
    article.author_ids_in_order = [authors(:hana).id]
    article
  end

  def read_next(article)
    get article_path(article)
    assert_response :success
    css_select(".related a").map(&:text)
  end

  test "stories sharing tags, never the story itself" do
    assert_equal [articles(:council_budget)], articles(:harbour_bridge).related.to_a
    assert_equal ["Council budget leaves library hours untouched"], read_next(articles(:harbour_bridge))
  end

  test "most shared tags first, then newest" do
    rates = story("Rates rise explained", "council, budget", Time.utc(2026, 9, 5))
    assert_equal [rates, articles(:harbour_bridge), articles(:port_profits)], articles(:council_budget).related.to_a
    assert_equal ["Rates rise explained", "Harbour Bridge tolls to rise in March", "Port profits climb on container traffic"],
                 read_next(articles(:council_budget))
  end

  test "drafts and stories still to come are left out" do
    articles(:ferry_strike).update!(tag_list: "council, transport")
    story("Council meets tomorrow", "council", 1.hour.from_now)
    assert_equal [articles(:council_budget)], articles(:harbour_bridge).related.to_a
  end

  test "at most four" do
    5.times { |i| story("Council story #{i}", "council", Time.utc(2026, 9, 1 + i)) }
    related = articles(:harbour_bridge).related.to_a
    assert_equal 4, related.size
    assert_equal articles(:council_budget), related.first
    assert_equal 4, read_next(articles(:harbour_bridge)).size
  end

  test "no list when nothing matches" do
    assert_empty articles(:rugby_final).related.to_a
    assert_empty read_next(articles(:rugby_final))
    assert_select ".related", 0
  end
end
