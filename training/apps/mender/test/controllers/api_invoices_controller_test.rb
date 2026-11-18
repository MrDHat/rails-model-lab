require "test_helper"

class ApiInvoicesControllerTest < ActionDispatch::IntegrationTest
  test "lists a patient's invoices" do
    get api_invoices_path(patient_id: patients(:julia).id), headers: api_headers, as: :json
    assert_equal ["MND-2026-00001"], response.parsed_body.map { _1["number"] }
  end

  test "shows an invoice" do
    get api_invoice_path("MND-2026-00001"), headers: api_headers, as: :json
    assert_response :success
    assert_equal 3600, response.parsed_body["balance_cents"]
    assert_equal 1, response.parsed_body["lines"].size
  end

  test "drafts aren't visible" do
    Invoice.create!(patient: patients(:julia), number: "MND-2026-09999")
    get api_invoice_path("MND-2026-09999"), headers: api_headers, as: :json
    assert_response :not_found
  end
end
