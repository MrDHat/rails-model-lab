require "test_helper"

class NewsroomSessionsControllerTest < ActionDispatch::IntegrationTest
  test "the newsroom needs a signed-in editor" do
    get newsroom_root_path
    assert_redirected_to new_newsroom_session_path
  end

  test "signing in and out" do
    post newsroom_session_path, params: { email: "owen@gazette.example", access_code: "0000" }
    assert_response :unprocessable_entity
    sign_in_editor editors(:owen)
    get newsroom_root_path
    assert_response :success
    assert_select ".drafts li", "Ferry crews vote on strike"
    delete newsroom_session_path
    get newsroom_root_path
    assert_redirected_to new_newsroom_session_path
  end
end
