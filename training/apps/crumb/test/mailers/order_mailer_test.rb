require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  test "receipt lists the items" do
    mail = OrderMailer.receipt(orders(:lea_morning))
    assert_equal ["lea@example.com"], mail.to
    assert_match "2 x Croissant", mail.body.to_s
  end
end
