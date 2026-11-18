require "test_helper"

class InvoiceBuilderTest < ActiveSupport::TestCase
  setup do
    travel_to Time.utc(2026, 6, 15, 18)
    @appointment = appointments(:julia_monday)
    @appointment.check_in!
    @appointment.complete!
  end

  teardown { travel_back }

  test "bills the treatment and claims the insurer's share" do
    invoice = InvoiceBuilder.for(@appointment)
    assert invoice.draft?
    assert_equal 18000, invoice.total_cents
    assert_equal 14400, invoice.insurer_share_cents
    assert_equal ["Physiotherapy session (2026-06-15)"], invoice.invoice_lines.map(&:description)
    assert_equal [insurers(:saude), 14400], [invoice.insurance_claim.insurer, invoice.insurance_claim.amount_cents]
  end

  test "patients without cover pay it all" do
    appointment = appointments(:tom_monday)
    appointment.check_in!
    appointment.complete!
    invoice = InvoiceBuilder.for(appointment)
    assert_equal 0, invoice.insurer_share_cents
    assert_nil invoice.insurance_claim
  end

  test "once per appointment, and only when completed" do
    InvoiceBuilder.for(@appointment)
    assert_raises(Invoice::NotPayable) { InvoiceBuilder.for(@appointment.reload) }
    assert_raises(Invoice::NotPayable) { InvoiceBuilder.for(appointments(:marcos_monday)) }
  end
end
