require "test_helper"

class SectionAtomFeedTest < ActionDispatch::IntegrationTest
  ATOM = { "a" => "http://www.w3.org/2005/Atom" }.freeze

  def feed_for(section)
    get section_path(section, format: :atom)
    assert_response :success
    assert_equal "application/atom+xml", response.media_type
    Nokogiri::XML(response.body).at_xpath("/a:feed", ATOM)
  end

  def text(node, path) = node.at_xpath(path, ATOM)&.text

  test "lists the section's live stories, newest first" do
    feed = feed_for(sections(:news))
    entries = feed.xpath("a:entry", ATOM)
    assert_equal ["Harbour Bridge tolls to rise in March", "Council budget leaves library hours untouched"],
                 entries.map { text(_1, "a:title") }
  end

  test "entries carry the link, summary, times and authors" do
    entry = feed_for(sections(:news)).at_xpath("a:entry", ATOM)
    article = articles(:harbour_bridge)
    assert_equal "http://www.example.com/articles/harbour-bridge-tolls-to-rise", entry.at_xpath("a:link", ATOM)["href"]
    assert_equal article.dek, text(entry, "a:summary")
    assert_equal article.published_at, Time.iso8601(text(entry, "a:published"))
    assert_equal article.updated_at, Time.iso8601(text(entry, "a:updated"))
    assert_equal ["Eli Moana", "Hana Reti"], entry.xpath("a:author/a:name", ATOM).map(&:text).sort
  end

  test "the feed's updated time is its newest change" do
    articles(:council_budget).update_columns(updated_at: Time.utc(2026, 9, 13, 20, 30))
    feed = feed_for(sections(:news))
    assert_equal Time.utc(2026, 9, 13, 20, 30), Time.iso8601(text(feed, "a:updated"))
  end

  test "at most twenty stories" do
    21.times do |i|
      Article.create!(section: sections(:sport), headline: "Round #{i + 1} results", status: :published,
                      published_at: Time.utc(2026, 9, 1, i))
    end
    titles = feed_for(sections(:sport)).xpath("a:entry/a:title", ATOM).map(&:text)
    assert_equal 20, titles.size
    assert_equal "Harbour Hawks win the provincial final", titles.first
    assert_not_includes titles, "Round 1 results"
  end

  test "the section page points feed readers at it" do
    get section_path(sections(:news))
    assert_select "head link[rel=alternate][type='application/atom+xml'][href='http://www.example.com/sections/news.atom']"
  end

  test "unknown sections have no feed" do
    get section_path("lifestyle", format: :atom)
    assert_response :not_found
  end
end
