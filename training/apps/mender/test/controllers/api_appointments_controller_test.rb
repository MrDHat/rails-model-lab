require "test_helper"

class ApiAppointmentsControllerTest < ActionDispatch::IntegrationTest
  setup { travel_to Time.utc(2026, 6, 14, 12) }
  teardown { travel_back }

  test "books an appointment" do
    post api_appointments_path, headers: api_headers, as: :json,
                                params: { patient_id: patients(:tom).id, practitioner_id: practitioners(:carla).id, treatment: "MASS",
                                          starts_at: "2026-06-15T10:00:00-03:00" }
    assert_response :created
    assert_equal({ "status" => "booked", "starts_at" => "2026-06-15T10:00:00-03:00", "ends_at" => "2026-06-15T11:00:00-03:00",
                   "practitioner" => "Carla Mendes", "treatment" => "MASS", "location" => "Pinheiros", "room" => "Studio" },
                 response.parsed_body.except("id"))
  end

  test "a treatment the practitioner doesn't offer is a 422" do
    post api_appointments_path, headers: api_headers, as: :json,
                                params: { patient_id: patients(:tom).id, practitioner_id: practitioners(:carla).id, treatment: "PILA",
                                          starts_at: "2026-06-15T10:00:00-03:00" }
    assert_response :unprocessable_entity
    assert_equal ["Treatment is not offered by Carla Mendes"], response.parsed_body["errors"]
  end

  test "lists a patient's upcoming appointments" do
    get api_appointments_path(patient_id: patients(:julia).id), headers: api_headers, as: :json
    assert_equal [appointments(:julia_monday).id], response.parsed_body.map { _1["id"] }
  end

  test "moves an appointment" do
    patch api_appointment_path(appointments(:julia_monday)), headers: api_headers, as: :json, params: { starts_at: "2026-06-17T09:00:00-03:00" }
    assert_response :success
    assert_equal "2026-06-17T09:45:00-03:00", response.parsed_body["ends_at"]
  end

  test "cancels an appointment" do
    delete api_appointment_path(appointments(:julia_monday)), headers: api_headers, as: :json
    assert_response :success
    assert_equal "cancelled", response.parsed_body["status"]
    delete api_appointment_path(appointments(:julia_monday)), headers: api_headers, as: :json
    assert_response :unprocessable_entity
  end
end
