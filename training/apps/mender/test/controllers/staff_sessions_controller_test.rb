require "test_helper"

class StaffSessionsControllerTest < ActionDispatch::IntegrationTest
  test "staff pages need a sign-in" do
    get staff_patients_path
    assert_redirected_to new_staff_session_path
  end

  test "signs in with the access code" do
    sign_in_staff staff_users(:rosa)
    get staff_patients_path
    assert_response :success
  end

  test "a wrong code is refused" do
    post staff_session_path, params: { email: "rosa@mender.example", access_code: "0000" }
    assert_response :unprocessable_entity
  end

  test "signs out" do
    sign_in_staff staff_users(:rosa)
    delete staff_session_path
    get staff_patients_path
    assert_redirected_to new_staff_session_path
  end
end
