require "test_helper"

class ApiReadersControllerTest < ActionDispatch::IntegrationTest
  test "sign up returns a token that works" do
    post api_reader_path, params: { reader: { email: "kai@example.com", display_name: "Kai", briefing: true } }, as: :json
    assert_response :created
    token = response.parsed_body["api_token"]
    assert token.present?

    get api_reader_path, headers: { "Authorization" => "Bearer #{token}" }, as: :json
    assert_equal ["kai@example.com", true], response.parsed_body.values_at("email", "briefing")
  end

  test "sign up errors" do
    post api_reader_path, params: { reader: { email: "mere@example.com", display_name: "M" } }, as: :json
    assert_response :unprocessable_entity
    assert_equal ["Email has already been taken"], response.parsed_body["errors"]
  end

  test "readers can change their name and briefing choice" do
    patch api_reader_path, params: { reader: { display_name: "Mere Tane", briefing: false } }, headers: api_headers, as: :json
    assert_response :success
    assert_equal ["Mere Tane", false], readers(:mere).reload.then { [_1.display_name, _1.briefing] }
  end

  test "readers can delete their account" do
    delete api_reader_path, headers: api_headers(:lou), as: :json
    assert_response :no_content
    assert_not Reader.exists?(readers(:lou).id)
  end
end
