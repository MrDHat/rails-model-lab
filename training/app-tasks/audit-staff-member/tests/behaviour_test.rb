require "test_helper"

class AuditStaffMemberTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup { travel_to Time.utc(2026, 6, 14, 12) }
  teardown { travel_back }

  test "status changes from the staff pages record who" do
    sign_in_staff staff_users(:rosa)
    patch staff_appointment_path(appointments(:julia_monday), event: "check_in")
    event = AuditEvent.last
    assert_equal ["appointment.checked_in", staff_users(:rosa)], [event.action, event.staff_user]
  end

  test "so do voided invoices, for whoever is signed in" do
    sign_in_staff staff_users(:helena)
    post void_staff_invoice_path(invoices(:julia_last_week)), params: { reason: "Duplicate" }
    assert_equal staff_users(:helena), AuditEvent.last.staff_user
    delete staff_session_path
    sign_in_staff staff_users(:rosa)
    patch staff_appointment_path(appointments(:marcos_monday)), params: { event: "cancel", reason: "Ill" }
    assert_equal staff_users(:rosa), AuditEvent.last.staff_user
  end

  test "API changes record no one, even after a staff request" do
    sign_in_staff staff_users(:rosa)
    patch staff_appointment_path(appointments(:julia_monday), event: "check_in")
    delete api_appointment_path(appointments(:marcos_monday)), headers: api_headers, as: :json
    assert_response :success
    event = AuditEvent.last
    assert_equal "appointment.cancelled", event.action
    assert_nil event.staff_user
  end

  test "jobs record no one, even right after a staff request" do
    sign_in_staff staff_users(:helena)
    post void_staff_invoice_path(invoices(:lucia_last_week).tap { _1.update_columns(status: Invoice::ISSUED) }), params: { reason: "Wrong patient" }
    InsurerGateway.reject_next = true
    ClaimSubmissionJob.perform_now(insurance_claims(:julia_last_week))
    event = AuditEvent.last
    assert_equal "claim.rejected", event.action
    assert_nil event.staff_user
  end

  test "changes made outside any request record no one" do
    appointments(:tom_monday).check_in!
    assert_nil AuditEvent.last.staff_user
  end
end
