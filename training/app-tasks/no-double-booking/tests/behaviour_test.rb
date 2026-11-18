require "test_helper"

class NoDoubleBookingTest < ActionDispatch::IntegrationTest
  setup { travel_to Time.utc(2026, 6, 14, 12) }
  teardown { travel_back }

  def book_in_app(practitioner, starts_at, treatment: "PHYS", patient: patients(:tom))
    post api_appointments_path, headers: api_headers, as: :json,
                                params: { patient_id: patient.id, practitioner_id: practitioners(practitioner).id, treatment: treatment, starts_at: starts_at }
  end

  test "the app can't book a start time that's taken" do
    assert_no_difference -> { Appointment.count } do
      book_in_app(:ana, "2026-06-15T09:00:00-03:00")
    end
    assert_response :unprocessable_entity
    assert_equal ["Starts at is already booked for this practitioner"], response.parsed_body["errors"]
  end

  test "nor can reception" do
    sign_in_staff staff_users(:rosa)
    assert_no_difference -> { Appointment.count } do
      post staff_appointments_path, params: { appointment: { patient_id: patients(:tom).id, practitioner_id: practitioners(:ana).id,
                                                             treatment_id: treatments(:physio).id, starts_at: "2026-06-15T11:00" } }
    end
    assert_response :unprocessable_entity
    assert_select ".errors li", "Starts at is already booked for this practitioner"
  end

  test "other practitioners can start at the same time" do
    book_in_app(:bruno, "2026-06-15T09:00:00-03:00")
    assert_response :created
  end

  test "a cancelled slot can be booked again" do
    appointments(:julia_monday).cancel!(reason: "Away")
    book_in_app(:ana, "2026-06-15T09:00:00-03:00")
    assert_response :created
    book_in_app(:ana, "2026-06-15T09:00:00-03:00", patient: patients(:lucia))
    assert_response :unprocessable_entity
  end

  test "moving onto a taken start time is refused" do
    patch api_appointment_path(appointments(:marcos_monday)), headers: api_headers, as: :json, params: { starts_at: "2026-06-15T09:00:00-03:00" }
    assert_response :unprocessable_entity
    assert_equal ["Starts at is already booked for this practitioner"], response.parsed_body["errors"]
    assert_equal Time.utc(2026, 6, 15, 14), appointments(:marcos_monday).reload.starts_at
  end

  test "appointments can still be moved to a free time, cancelled and completed" do
    appointment = appointments(:julia_monday)
    appointment.reschedule!(Time.utc(2026, 6, 15, 13))
    appointment.check_in!
    appointment.complete!
    assert appointment.reload.completed?
    appointments(:marcos_monday).cancel!(reason: "Away")
  end
end
