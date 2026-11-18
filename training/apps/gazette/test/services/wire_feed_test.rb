require "test_helper"

class WireFeedTest < ActiveSupport::TestCase
  def delivery(*items) = { items: items }.to_json

  def item(guid, **attrs)
    { guid: guid, headline: "Item #{guid}", summary: "Summary", body: "Body text", section: "business",
      filed_at: "2026-09-14T06:10:00+12:00", keywords: %w[Port shipping] }.merge(attrs)
  end

  test "new items become drafts in their section" do
    import = WireFeed.import(delivery(item("NZW-2001")))
    article = Article.find_by!(wire_guid: "NZW-2001")
    assert article.draft?
    assert_equal sections(:business), article.section
    assert_equal %w[port shipping], article.tags.map(&:name).sort
    assert_equal Time.utc(2026, 9, 13, 18, 10), article.created_at
    assert_equal [1, 1, 0, 0], [import.items_count, import.created_count, import.skipped_count, import.failed_count]
  end

  test "unknown sections land in Wire" do
    WireFeed.import(delivery(item("NZW-2002", section: "lifestyle")))
    assert_equal sections(:wire), Article.find_by!(wire_guid: "NZW-2002").section
  end

  test "items already imported are skipped" do
    import = WireFeed.import(delivery(item("NZW-1001"), item("NZW-2003")))
    assert_equal [2, 1, 1], [import.items_count, import.created_count, import.skipped_count]
    assert_equal "Storm warning for the lower North Island", articles(:wire_storm).reload.headline
  end

  test "invalid items are counted as failed and the rest still come in" do
    import = WireFeed.import(delivery(item("NZW-2004", headline: ""), item("NZW-2005")))
    assert_equal [1, 1], [import.created_count, import.failed_count]
    assert Article.exists?(wire_guid: "NZW-2005")
  end
end
