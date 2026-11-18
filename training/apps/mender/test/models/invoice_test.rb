require "test_helper"

class InvoiceTest < ActiveSupport::TestCase
  setup { travel_to Time.utc(2026, 6, 14, 12) }
  teardown { travel_back }

  test "numbers new invoices by year" do
    invoice = Invoice.create!(patient: patients(:tom))
    assert_match(/\AMND-2026-\d{5}\z/, invoice.number)
  end

  test "the patient pays what the insurer doesn't" do
    invoice = invoices(:julia_last_week)
    assert_equal 3600, invoice.patient_share_cents
    assert_equal 3600, invoice.balance_cents
  end

  test "is paid once the balance is covered" do
    invoice = invoices(:julia_last_week)
    invoice.record_payment!(amount_cents: 1000, method: "card")
    assert invoice.reload.issued?
    invoice.record_payment!(amount_cents: 2600, method: "pix", reference: "E2E-9")
    assert invoice.reload.paid?
    assert_equal 0, invoice.balance_cents
  end

  test "only issued invoices take payments" do
    assert_raises(Invoice::NotPayable) { invoices(:lucia_last_week).record_payment!(amount_cents: 100, method: "card") }
  end

  test "voiding is audited" do
    invoices(:julia_last_week).void!(reason: "Duplicate")
    assert invoices(:julia_last_week).reload.void?
    assert_equal({ "reason" => "Duplicate" }, AuditEvent.last.details)
  end

  test "issuing sets the due date" do
    invoice = Invoice.create!(patient: patients(:tom))
    invoice.issue!(on: Date.new(2026, 6, 14))
    assert_equal Date.new(2026, 7, 14), invoice.due_on
  end
end
