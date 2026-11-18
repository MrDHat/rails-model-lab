require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  test "new stories get a slug" do
    article = Article.create!(section: sections(:news), headline: "Ferry timetable changes")
    assert article.slug.present?
    assert_equal article, Article.find_by(slug: article.to_param)
  end

  test "live means published and not in the future" do
    assert_includes Article.live, articles(:harbour_bridge)
    assert_not_includes Article.live, articles(:ferry_strike)
    articles(:port_profits).update!(published_at: 1.hour.from_now)
    assert_not_includes Article.live, articles(:port_profits)
  end

  test "publishing needs a byline and keeps the first publication time" do
    article = Article.create!(section: sections(:news), headline: "Ferry timetable changes")
    assert_raises(Article::InvalidTransition) { article.publish! }

    article.author_ids_in_order = [authors(:eli).id]
    article.publish!
    assert article.reload.published?
    assert_equal Time.current, article.published_at

    article.unpublish!
    travel 1.hour
    article.publish!
    assert_equal 1.hour.ago, article.reload.published_at
  end

  test "spiked stories can't be published and published ones can't be spiked" do
    assert_raises(Article::InvalidTransition) { articles(:old_rumour).publish! }
    assert_raises(Article::InvalidTransition) { articles(:harbour_bridge).spike! }
    articles(:ferry_strike).spike!
    assert articles(:ferry_strike).spiked?
  end

  test "scheduling sets publish_at in the future" do
    article = articles(:ferry_strike)
    assert_raises(Article::InvalidTransition) { article.schedule!(1.minute.ago) }
    article.schedule!(3.hours.from_now)
    assert article.ready?
    assert_equal 3.hours.from_now, article.publish_at
    assert_includes Article.due(4.hours.from_now), article
    assert_not_includes Article.due, article
  end

  test "byline order follows the authorship positions when saved from the editor" do
    article = articles(:ferry_strike)
    article.author_ids_in_order = [authors(:hana).id, authors(:eli).id]
    assert_equal [0, 1], [authors(:hana), authors(:eli)].map { article.authorships.find_by(author: _1).position }
    article.author_ids_in_order = [authors(:eli).id]
    assert_equal [authors(:eli)], article.authors.reload.to_a
  end

  test "byline names every author" do
    byline = articles(:harbour_bridge).byline
    assert_match "Eli Moana", byline
    assert_match "Hana Reti", byline
    assert_nil articles(:wire_storm).byline
  end

  test "tag list is case-insensitive and reuses tags" do
    article = articles(:ferry_strike)
    assert_no_difference("Tag.count") { article.update!(tag_list: "Transport, council,transport") }
    assert_equal %w[council transport], article.tags.map(&:name).sort
    assert_difference("Tag.count", 1) { article.update!(tag_list: "ferries") }
  end

  test "search matches headline, standfirst and body, and treats % literally" do
    assert_equal [articles(:port_profits)], Article.live.search("container").to_a
    assert_equal [articles(:council_budget)], Article.live.search("6 per cent").to_a
    assert_empty Article.live.search("100%")
  end

  test "reading time is at least a minute" do
    assert_equal 1, articles(:old_rumour).reading_minutes
    assert_equal 3, Article.new(body: "word " * 500).reading_minutes
  end

  test "comments are open on live stories unless closed site-wide or on the story" do
    article = articles(:harbour_bridge)
    assert article.comments_open?
    article.comments_enabled = false
    assert_not article.comments_open?
    article.comments_enabled = true
    Setting[:comments_open] = false
    assert_not article.comments_open?
  end

  test "views are counted" do
    article = articles(:rugby_final)
    article.record_view!
    assert_equal 511, article.reload.views_count
  end
end
