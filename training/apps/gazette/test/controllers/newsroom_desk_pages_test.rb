require "test_helper"

class NewsroomDeskPagesTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "moderating comments" do
    sign_in_editor editors(:owen)
    get newsroom_comments_path
    assert_select ".comment", 1
    patch newsroom_comment_path(comments(:harbour_sam), status: "approved")
    assert comments(:harbour_sam).reload.approved?
    delete newsroom_comment_path(comments(:harbour_mere))
    assert_not Comment.exists?(comments(:harbour_mere).id)
    assert_equal 1, articles(:harbour_bridge).reload.comments_count
  end

  test "letters" do
    sign_in_editor editors(:owen)
    get newsroom_letters_path(status: "received")
    assert_select "tr", 1
    get newsroom_letter_path(letters(:bus_timetable))
    assert_select ".from", /June Hart, Petone/
    patch newsroom_letter_path(letters(:bus_timetable), status: "accepted")
    assert letters(:bus_timetable).reload.accepted?
  end

  test "renaming a section" do
    sign_in_editor editors(:owen)
    patch newsroom_section_path(sections(:opinion)), params: { section: { name: "Comment" } }
    assert_redirected_to newsroom_sections_path
    assert_equal "Comment", sections(:opinion).reload.name
    patch newsroom_section_path(sections(:opinion)), params: { section: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "readers: anyone can look, only the chief can delete" do
    sign_in_editor editors(:owen)
    get newsroom_readers_path(q: "lou")
    assert_select "tr", 1
    delete newsroom_reader_path(readers(:lou))
    assert Reader.exists?(readers(:lou).id)

    delete newsroom_session_path
    sign_in_editor editors(:grace)
    delete newsroom_reader_path(readers(:lou))
    assert_redirected_to newsroom_readers_path
    assert_not Reader.exists?(readers(:lou).id)
  end

  test "settings are for the chief" do
    sign_in_editor editors(:owen)
    get edit_newsroom_settings_path
    assert_redirected_to newsroom_root_path

    delete newsroom_session_path
    sign_in_editor editors(:grace)
    patch newsroom_settings_path, params: { settings: { comments_open: "0", briefing_size: "3" } }
    assert_equal [false, 3], [Setting[:comments_open], Setting[:briefing_size]]
  end

  test "pasting a wire delivery queues an import" do
    sign_in_editor editors(:owen)
    assert_enqueued_with(job: WireImportJob) do
      post newsroom_wire_imports_path, params: { payload: { items: [] }.to_json }
    end
    post newsroom_wire_imports_path, params: { payload: "<xml/>" }
    assert_equal "That isn't a wire delivery.", flash[:alert]
  end
end
