require "test_helper"

class ReceiptSignedLinkTest < ActionDispatch::IntegrationTest
  def receipt_path_from_email(order = orders(:lea_morning))
    body = OrderMailer.receipt(order).body.to_s
    url = body[%r{http://example\.com/receipts/\S+}] or flunk("no receipt link in #{body}")
    url.delete_prefix("http://example.com")
  end

  test "the link shows the receipt" do
    get receipt_path_from_email
    assert_response :success
    assert_includes response.body, "2 x Croissant"
    assert_includes response.body, "1 x Baguette"
    assert_includes response.body, "4.00"
  end

  test "each order gets its own link" do
    get receipt_path_from_email(orders(:tom_evening))
    assert_includes response.body, "1 x Baguette"
    assert_not_includes response.body, "Croissant"
  end

  test "ids and tampered tokens are 404" do
    get "/receipts/#{orders(:lea_morning).id}"
    assert_response :not_found
    get "#{receipt_path_from_email}x"
    assert_response :not_found
    get "/receipts/#{orders(:lea_morning).signed_id}"
    assert_response :not_found
  end

  test "links expire after 30 days" do
    path = receipt_path_from_email
    travel 29.days
    get path
    assert_response :success
    travel 2.days
    get path
    assert_response :not_found
  end
end
