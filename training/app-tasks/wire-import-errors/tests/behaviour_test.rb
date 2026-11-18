require "test_helper"

class WireImportErrorsTest < ActiveSupport::TestCase
  def item(guid, **attrs)
    { guid: guid, headline: "Item #{guid}", body: "Body", section: "news", filed_at: "2026-09-14T06:10:00+12:00" }.merge(attrs)
  end

  def delivery
    { items: [
      item("NZW-4001"),
      item("NZW-4002", filed_at: "14/09/2026 6:10am"),
      item("NZW-4003").except(:headline),
      item("NZW-4004", headline: ""),
      item("NZW-1001"),
      item("NZW-4005")
    ] }.to_json
  end

  def reports_for(guid) = ErrorTracker.reports.select { _1.context.values.include?(guid) }

  test "bad items are skipped and counted, good ones come in" do
    import = WireFeed.import(delivery)
    assert_equal [6, 2, 1, 3], [import.items_count, import.created_count, import.skipped_count, import.failed_count]
    assert_equal %w[NZW-4001 NZW-4005], Article.where(wire_guid: %w[NZW-4001 NZW-4002 NZW-4003 NZW-4004 NZW-4005]).pluck(:wire_guid).sort
  end

  test "each failure reaches the error tracker with its guid" do
    WireFeed.import(delivery)
    assert_equal 1, reports_for("NZW-4002").size
    assert_kind_of ArgumentError, reports_for("NZW-4002").first.error
    assert_kind_of KeyError, reports_for("NZW-4003").first.error
    assert_kind_of ActiveRecord::RecordInvalid, reports_for("NZW-4004").first.error
    assert_empty reports_for("NZW-4001")
    assert_empty reports_for("NZW-1001")
    assert ErrorTracker.reports.all?(&:handled)
  end

  test "the import job finishes" do
    assert_difference("WireImport.count") { WireImportJob.perform_now(delivery) }
    assert_equal 3, WireImport.order(:id).last.failed_count
  end
end
