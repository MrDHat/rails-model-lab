require "test_helper"

class StaffInvoicesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_staff staff_users(:rosa) }

  test "lists issued invoices" do
    get staff_invoices_path
    assert_select "table.invoices tbody tr", 1
  end

  test "records a payment" do
    post pay_staff_invoice_path(invoices(:julia_last_week)), params: { amount_cents: 3600, method: "pix", reference: "E2E-7" }
    assert invoices(:julia_last_week).reload.paid?
  end

  test "issuing emails the patient and submits the claim" do
    invoice = Invoice.create!(patient: patients(:julia))
    invoice.create_insurance_claim!(insurer: insurers(:saude), amount_cents: 1000)
    assert_enqueued_jobs 2 do
      post issue_staff_invoice_path(invoice)
    end
    assert invoice.reload.issued?
  end

  test "voids" do
    post void_staff_invoice_path(invoices(:julia_last_week)), params: { reason: "Wrong patient" }
    assert invoices(:julia_last_week).reload.void?
  end
end
