require "test_helper"

class ApiAuthenticationTest < ActionDispatch::IntegrationTest
  test "needs a client token" do
    get api_treatments_path, as: :json
    assert_response :unauthorized
    get api_treatments_path, headers: { "Authorization" => "Bearer nope" }, as: :json
    assert_response :unauthorized
  end

  test "lists active treatments" do
    get api_treatments_path, headers: api_headers, as: :json
    assert_response :success
    assert_equal %w[PILA PHYS MASS SPRT], response.parsed_body.map { _1["code"] }
  end

  test "unknown records are a JSON 404" do
    get api_patient_path(0), headers: api_headers, as: :json
    assert_response :not_found
    assert_equal({ "errors" => ["Not found"] }, response.parsed_body)
  end
end
