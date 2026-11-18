require "test_helper"

class StaffManagerPagesTest < ActionDispatch::IntegrationTest
  test "the monthly report is for managers" do
    sign_in_staff staff_users(:rosa)
    get staff_report_path(month: "2026-06")
    assert_redirected_to staff_root_path
  end

  test "the monthly report" do
    sign_in_staff staff_users(:helena)
    get staff_report_path(month: "2026-06")
    assert_response :success
    assert_select "#status_completed td:last-child", "2"
    assert_select "#cancellation_rate", "16.7%"
    assert_select "#revenue", "R$ 180,00"
  end

  test "exports an insurer's claims" do
    sign_in_staff staff_users(:helena)
    get export_staff_claims_path(insurer: "SAUDE", month: "2026-06")
    assert_equal "text/csv", response.media_type
    assert_equal 2, response.body.lines.size
  end

  test "edits a practitioner" do
    sign_in_staff staff_users(:helena)
    patch staff_practitioner_path(practitioners(:bruno)), params: { practitioner: { specialty: "Pilates and rehab" } }
    assert_equal "Pilates and rehab", practitioners(:bruno).reload.specialty
  end

  test "the waitlist" do
    sign_in_staff staff_users(:rosa)
    get staff_waitlist_entries_path
    assert_select "table.waitlist tbody tr", 1
  end
end
