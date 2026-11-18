require "test_helper"

class PatientPhoneFormatTest < ActionDispatch::IntegrationTest
  def sign_up(phone, email: "pedro@example.com")
    post api_patients_path, headers: api_headers, as: :json,
                            params: { patient: { name: "Pedro Santos", email: email, phone: phone } }
  end

  test "sign-ups store E.164 whatever the format" do
    sign_up("(11) 91234-5678")
    assert_response :created
    assert_equal "+5511912345678", Patient.find_by!(email: "pedro@example.com").phone
    sign_up("21 3456 7890", email: "ines@example.com")
    assert_equal "+552134567890", Patient.find_by!(email: "ines@example.com").phone
  end

  test "so do the staff pages" do
    sign_in_staff staff_users(:rosa)
    patch staff_patient_path(patients(:tom)), params: { patient: { phone: "+55 (11) 99999-0004" } }
    assert_equal "+5511999990004", patients(:tom).reload.phone
  end

  test "looks patients up by any format" do
    ["(11) 98765-0002", "11 98765 0002", "+55 11 98765-0002", "+5511987650002"].each do |phone|
      get lookup_api_patients_path(phone: phone), headers: api_headers, as: :json
      assert_response :success, phone
      assert_equal patients(:marcos).id, response.parsed_body["id"], phone
    end
  end

  test "a number that's taken is refused however it's written" do
    sign_up("(11) 98765-0001")
    assert_response :unprocessable_entity
    assert_equal ["Phone has already been taken"], response.parsed_body["errors"]
    assert_equal 1, Patient.where(phone: "+5511987650001").count
  end

  test "unknown numbers are still a 404" do
    get lookup_api_patients_path(phone: "(11) 90000-0000"), headers: api_headers, as: :json
    assert_response :not_found
  end
end
