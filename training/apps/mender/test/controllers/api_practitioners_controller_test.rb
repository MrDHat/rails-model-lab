require "test_helper"

class ApiPractitionersControllerTest < ActionDispatch::IntegrationTest
  test "lists active practitioners" do
    get api_practitioners_path, headers: api_headers, as: :json
    assert_equal ["Ana Souza", "Bruno Lima", "Carla Mendes"], response.parsed_body.map { _1["name"] }
    assert_equal %w[PHYS SPRT], response.parsed_body.first["treatments"]
  end

  test "filters by treatment" do
    get api_practitioners_path(treatment: "PILA"), headers: api_headers, as: :json
    assert_equal ["Bruno Lima"], response.parsed_body.map { _1["name"] }
  end
end
