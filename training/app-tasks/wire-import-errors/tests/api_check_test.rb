require "test_helper"

class WireImportErrorsApiTest < ActiveSupport::TestCase
  class Listener
    attr_reader :errors

    def initialize = @errors = []
    def report(error, **) = @errors << error
  end

  test "failures go through Rails.error" do
    listener = Listener.new
    Rails.error.subscribe(listener)
    payload = { items: [{ guid: "NZW-5001", headline: "Bad date", section: "news", filed_at: "soon" }] }.to_json
    WireFeed.import(payload)
    assert_equal 1, listener.errors.size
  ensure
    Rails.error.unsubscribe(listener)
  end
end
