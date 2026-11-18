require "test_helper"

class InvoicePollingEtagTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Time.utc(2026, 6, 14, 12)
    @invoice = invoices(:julia_last_week)
  end

  teardown { travel_back }

  def poll(headers = {})
    get api_invoice_path(@invoice.number), headers: api_headers.merge(headers), as: :json
  end

  def poll_again
    etag, modified = response.headers["ETag"], response.headers["Last-Modified"]
    assert etag.present?, "no ETag"
    assert modified.present?, "no Last-Modified"
    travel 5.seconds
    poll("If-None-Match" => etag, "If-Modified-Since" => modified)
  end

  test "an unchanged invoice is a 304 with no body" do
    poll
    assert_response :success
    poll_again
    assert_response :not_modified
    assert_empty response.body
  end

  test "the ETag alone is enough" do
    poll
    etag = response.headers["ETag"]
    poll("If-None-Match" => etag)
    assert_response :not_modified
  end

  test "a partial payment changes it" do
    poll
    travel 1.minute
    @invoice.record_payment!(amount_cents: 1000, method: "card")
    poll_again
    assert_response :success
    assert_equal 2600, response.parsed_body["balance_cents"]
  end

  test "a changed line changes it" do
    poll
    travel 1.minute
    @invoice.invoice_lines.first.update!(unit_price_cents: 20000)
    poll_again
    assert_response :success
    assert_equal 20000, response.parsed_body["lines"].first["unit_price_cents"]
  end

  test "voiding changes it" do
    poll
    travel 1.minute
    @invoice.void!(reason: "Duplicate")
    poll_again
    assert_response :success
    assert_equal "void", response.parsed_body["status"]
  end

  test "another invoice's tag doesn't match" do
    get api_invoice_path("MND-2026-00002"), headers: api_headers, as: :json
    poll("If-None-Match" => response.headers["ETag"])
    assert_response :success
    assert_equal "MND-2026-00001", response.parsed_body["number"]
  end
end
