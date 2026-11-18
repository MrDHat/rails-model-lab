require "test_helper"

class ApiSlotsControllerTest < ActionDispatch::IntegrationTest
  setup { travel_to Time.utc(2026, 6, 14, 12) }
  teardown { travel_back }

  test "lists free start times" do
    get api_slots_path(practitioner_id: practitioners(:ana).id, treatment: "SPRT", date: "2026-06-15"), headers: api_headers, as: :json
    assert_response :success
    assert_equal "2026-06-15T08:00:00-03:00", response.parsed_body["slots"].first
  end

  test "a bad date is a 400" do
    get api_slots_path(practitioner_id: practitioners(:ana).id, treatment: "SPRT", date: "15/06"), headers: api_headers, as: :json
    assert_response :bad_request
  end
end
