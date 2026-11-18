require "test_helper"

class ApiPatientsControllerTest < ActionDispatch::IntegrationTest
  test "signs a patient up" do
    post api_patients_path, headers: api_headers, as: :json,
                            params: { patient: { name: "Pedro Santos", email: "pedro@example.com", phone: "+5511912345678", locale: "pt-BR" } }
    assert_response :created
    assert_equal "pedro@example.com", response.parsed_body["email"]
  end

  test "invalid sign-ups are a 422" do
    post api_patients_path, headers: api_headers, as: :json, params: { patient: { name: "", email: "x", phone: "1" } }
    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"], "Name can't be blank"
  end

  test "finds a patient by phone" do
    get lookup_api_patients_path(phone: "+5511987650002"), headers: api_headers, as: :json
    assert_response :success
    assert_equal patients(:marcos).id, response.parsed_body["id"]
  end

  test "archived patients aren't found" do
    get lookup_api_patients_path(phone: "+5511987650005"), headers: api_headers, as: :json
    assert_response :not_found
  end
end
