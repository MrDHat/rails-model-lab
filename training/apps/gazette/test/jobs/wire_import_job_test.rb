require "test_helper"

class WireImportJobTest < ActiveJob::TestCase
  test "imports the delivery" do
    payload = { items: [{ guid: "NZW-3001", headline: "Snow closes the Remutaka Hill road", section: "news" }] }.to_json
    assert_difference("WireImport.count") { WireImportJob.perform_now(payload) }
    assert Article.exists?(wire_guid: "NZW-3001")
  end
end
