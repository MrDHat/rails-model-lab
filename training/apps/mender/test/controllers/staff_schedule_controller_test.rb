require "test_helper"

class StaffScheduleControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_staff staff_users(:rosa) }

  test "shows a location's day" do
    get staff_schedule_path(location_id: locations(:paulista).id, date: "2026-06-15")
    assert_response :success
    assert_equal ["Julia Costa", "Tom Becker", "Marcos Oliveira"], css_select("table.schedule tbody tr td:nth-child(2)").map(&:text)
    assert_select "#appointment_#{appointments(:julia_monday).id} td", text: "09:00–09:45"
  end

  test "practitioners land on their own location" do
    delete staff_session_path
    sign_in_staff staff_users(:ana)
    get staff_schedule_path(date: "2026-06-08")
    assert_select "h1", /Paulista/
    assert_select "#appointment_#{appointments(:julia_last_week).id} td:last-child", "MND-2026-00001"
  end
end
