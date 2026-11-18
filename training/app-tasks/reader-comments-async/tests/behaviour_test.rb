require "test_helper"

class ReaderCommentsAsyncTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  def add_comments(reader, count)
    count.times { |i| Comment.create!(article: articles(:council_budget), reader: reader, body: "Comment #{i}") }
    Comment.where(reader: reader).update_all(status: Comment.statuses[:approved])
  end

  test "deleting an account from the app leaves the comments to a job" do
    add_comments readers(:mere), 5
    clear_enqueued_jobs
    assert_no_difference("Comment.count") do
      delete api_reader_path, headers: api_headers(:mere), as: :json
    end
    assert_response :no_content
    assert_not Reader.exists?(readers(:mere).id)
    assert_equal 5, articles(:council_budget).reload.comments_count

    perform_enqueued_jobs
    assert_not Comment.exists?(reader_id: readers(:mere).id)
    assert_equal 0, articles(:council_budget).reload.comments_count
    assert_equal 1, articles(:harbour_bridge).reload.comments_count
  end

  test "so does the chief editor deleting one" do
    add_comments readers(:sam), 3
    sign_in_editor editors(:grace)
    clear_enqueued_jobs
    assert_no_difference("Comment.count") { delete newsroom_reader_path(readers(:sam)) }
    assert_redirected_to newsroom_readers_path

    perform_enqueued_jobs
    assert_not Comment.exists?(reader_id: readers(:sam).id)
    assert_equal [0, 1], articles(:council_budget, :harbour_bridge).map { _1.reload.comments_count }
  end

  test "other readers' comments stay" do
    delete api_reader_path, headers: api_headers(:lou), as: :json
    perform_enqueued_jobs
    assert_equal 2, Comment.where(reader: readers(:mere, :sam)).count
    assert_equal 0, articles(:rugby_final).reload.comments_count
  end
end
