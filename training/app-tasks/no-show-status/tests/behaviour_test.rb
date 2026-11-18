require "test_helper"

class NoShowStatusTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @appointment = appointments(:julia_monday)
    travel_to Time.utc(2026, 6, 15, 12, 20)
    sign_in_staff staff_users(:rosa)
  end

  teardown { travel_back }

  def mark(appointment = @appointment) = patch(staff_appointment_path(appointment, event: "no_show"))
  def stored_status(appointment = @appointment) = Appointment.connection.select_value("SELECT status FROM appointments WHERE id = #{appointment.id}")

  test "a booked appointment that has started can be marked" do
    get staff_appointment_path(@appointment)
    assert_select "form[action=?] button", staff_appointment_path(@appointment, event: "no_show"), text: "Mark no-show"
    mark
    assert_redirected_to staff_appointment_path(@appointment)
    assert_equal 4, stored_status
    assert @appointment.reload.no_show?
    assert_equal [@appointment], Appointment.no_show.to_a
  end

  test "it shows as no_show" do
    mark
    get api_appointment_path(@appointment), headers: api_headers, as: :json
    assert_equal "no_show", response.parsed_body["status"]
    get staff_schedule_path(location_id: locations(:paulista).id, date: "2026-06-15")
    assert_select "tr#appointment_#{@appointment.id}.no_show"
  end

  test "it is audited" do
    mark
    event = AuditEvent.last
    assert_equal ["appointment.no_show", { "from" => "booked" }], [event.action, event.details]
  end

  test "appointments still to start can't be marked" do
    mark(appointments(:marcos_monday))
    assert_equal "only booked appointments that have started can be marked no-show", flash[:alert]
    assert_equal 0, stored_status(appointments(:marcos_monday))
  end

  test "nor can other statuses" do
    mark(appointments(:julia_last_week))
    assert_equal "only booked appointments that have started can be marked no-show", flash[:alert]
    assert_equal 2, stored_status(appointments(:julia_last_week))
    mark(appointments(:marcos_cancelled))
    assert_equal 3, stored_status(appointments(:marcos_cancelled))
  end

  test "the monthly report counts no-shows" do
    mark
    delete staff_session_path
    sign_in_staff staff_users(:helena)
    get staff_report_path(month: "2026-06")
    assert_select "#status_no_show td:last-child", "1"
    assert_select "#status_booked td:last-child", "2"
    assert_equal 1, MonthlyReport.new(Date.new(2026, 6, 1)).counts_by_status["no_show"]
  end

  test "the slot isn't offered to the waitlist" do
    assert_no_enqueued_jobs(only: WaitlistOfferJob) { mark }
    assert_nil waitlist_entries(:tom_wants_ana).reload.offered_at
  end

  test "the other statuses work as before" do
    @appointment.check_in!
    @appointment.complete!
    assert_equal 2, stored_status
    appointments(:marcos_monday).cancel!(reason: "Away")
    assert_equal 3, stored_status(appointments(:marcos_monday))
    assert_equal [appointments(:marcos_monday), appointments(:marcos_cancelled)].sort_by(&:id),
                 Appointment.where(patient: patients(:marcos)).reject { _1.status_name != "cancelled" }.sort_by(&:id)
  end
end
