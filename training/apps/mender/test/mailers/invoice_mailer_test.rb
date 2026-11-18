require "test_helper"

class InvoiceMailerTest < ActionMailer::TestCase
  test "issued" do
    mail = InvoiceMailer.issued(invoices(:julia_last_week))
    assert_equal "Your Mender invoice MND-2026-00001", mail.subject
    assert_includes mail.body.to_s, "Your insurer covers R$ 144.00"
    assert_includes mail.body.to_s, "You owe R$ 36.00"
  end
end
