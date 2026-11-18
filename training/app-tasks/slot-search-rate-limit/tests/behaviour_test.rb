require "test_helper"

class SlotSearchRateLimitTest < ActionDispatch::IntegrationTest
  setup { Rails.cache.clear }

  def search(client = :ios)
    get api_slots_path(practitioner_id: practitioners(:ana).id, treatment: "PHYS", date: "2026-06-17"), headers: api_headers(client), as: :json
  end

  test "the 31st search in a minute is refused" do
    travel_to Time.utc(2026, 6, 14, 12, 0, 5) do
      30.times do
        search
        assert_response :success
      end
      search
      assert_response :too_many_requests
      assert_equal({ "errors" => ["Too many slot searches, try again in a minute"] }, response.parsed_body)
    end
  end

  test "other clients and other endpoints aren't affected" do
    travel_to Time.utc(2026, 6, 14, 12, 0, 5) do
      31.times { search }
      assert_response :too_many_requests
      search(:android)
      assert_response :success
      get api_treatments_path, headers: api_headers, as: :json
      assert_response :success
      get api_practitioners_path, headers: api_headers, as: :json
      assert_response :success
    end
  end

  test "the limit lifts after a minute" do
    travel_to(Time.utc(2026, 6, 14, 12, 0, 5)) { 31.times { search } }
    travel_to(Time.utc(2026, 6, 14, 12, 1, 30)) do
      search
      assert_response :success
    end
  end

  test "unauthenticated requests are still a 401" do
    get api_slots_path(practitioner_id: practitioners(:ana).id, treatment: "PHYS", date: "2026-06-17"), as: :json
    assert_response :unauthorized
  end
end
