require "test_helper"

class AppointmentMovedTextTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    travel_to Time.utc(2026, 6, 14, 12)
    @appointment = appointments(:julia_monday)
  end

  teardown { travel_back }

  def moved_jobs = enqueued_jobs.select { _1[:job].to_s == "AppointmentMovedJob" }

  test "moving it in the app texts the patient from a job" do
    patch api_appointment_path(@appointment), headers: api_headers, as: :json, params: { starts_at: "2026-06-17T09:00:00-03:00" }
    assert_response :success
    assert_equal 1, moved_jobs.size
    assert_empty SmsGateway.sent
    perform_enqueued_jobs
    assert_equal [{ to: "+5511987650001", body: "Hi Julia, your appointment with Ana Souza has moved to Wed 17 Jun, 09:00 at Mender Paulista." }],
                 SmsGateway.sent
  end

  test "so does moving it on the staff page, or anywhere else" do
    sign_in_staff staff_users(:rosa)
    patch staff_appointment_path(@appointment), params: { starts_at: "2026-06-17T10:00" }
    assert_equal 1, moved_jobs.size
    appointments(:tom_monday).update!(starts_at: Time.utc(2026, 6, 16, 13), ends_at: Time.utc(2026, 6, 16, 14))
    assert_equal 2, moved_jobs.size
    perform_enqueued_jobs(only: AppointmentMovedJob)
    assert_equal ["+5511987650001", "+5511987650004"], SmsGateway.sent.map { _1[:to] }
    assert_includes SmsGateway.sent.last[:body], "has moved to Tue 16 Jun, 10:00"
  end

  test "other changes don't text" do
    @appointment.update!(notes: "Bring the MRI report")
    @appointment.check_in!
    appointments(:marcos_monday).cancel!(reason: "Away")
    Booking.create!(patient: patients(:tom), practitioner: practitioners(:ana), treatment: treatments(:physio), starts_at: Time.utc(2026, 6, 17, 13))
    @appointment.reload.update!(starts_at: @appointment.starts_at)
    assert_empty moved_jobs
  end

  test "a rolled-back move doesn't text" do
    Appointment.transaction do
      @appointment.reschedule!(Time.utc(2026, 6, 17, 12))
      raise ActiveRecord::Rollback
    end
    assert_empty moved_jobs
    assert_equal Time.utc(2026, 6, 15, 12), @appointment.reload.starts_at
  end

  test "a refused move doesn't text" do
    patch api_appointment_path(appointments(:julia_last_week)), headers: api_headers, as: :json, params: { starts_at: "2026-06-17T09:00:00-03:00" }
    assert_response :unprocessable_entity
    assert_empty moved_jobs
  end
end
