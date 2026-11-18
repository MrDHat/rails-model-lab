require "test_helper"

class ReaderTokenRotateTest < ActionDispatch::IntegrationTest
  test "a new token replaces the old one" do
    old = readers(:mere).api_token
    post "/api/reader/token", headers: api_headers(:mere), as: :json
    assert_response :success
    token = response.parsed_body["api_token"]
    assert token.present?
    assert_not_equal old, token

    get api_reader_path, headers: { "Authorization" => "Bearer #{token}" }, as: :json
    assert_response :success
    assert_equal "mere@example.com", response.parsed_body["email"]

    get api_reader_path, headers: { "Authorization" => "Bearer #{old}" }, as: :json
    assert_response :unauthorized
  end

  test "each rotation gives a different token, and other readers keep theirs" do
    post "/api/reader/token", headers: api_headers(:mere), as: :json
    first = response.parsed_body["api_token"]
    post "/api/reader/token", headers: { "Authorization" => "Bearer #{first}" }, as: :json
    assert_not_equal first, response.parsed_body["api_token"]

    get api_reader_path, headers: api_headers(:sam), as: :json
    assert_response :success
  end

  test "needs the current token" do
    post "/api/reader/token", as: :json
    assert_response :unauthorized
  end
end
