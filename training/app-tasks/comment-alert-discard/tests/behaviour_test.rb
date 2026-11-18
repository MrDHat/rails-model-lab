require "test_helper"

class CommentAlertDiscardTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  def post_comment(body)
    post api_article_comments_path(articles(:harbour_bridge)), params: { comment: { body: body } },
         headers: api_headers(:lou), as: :json
    assert_response :created
    Comment.find(response.parsed_body["id"])
  end

  test "an alert for a comment deleted as spam is dropped" do
    comment = post_comment("Cheap watches at example.biz")
    sign_in_editor editors(:owen)
    delete newsroom_comment_path(comment)

    assert_no_emails { perform_enqueued_jobs }
    assert_no_enqueued_jobs only: CommentAlertJob
  end

  test "alerts for comments that are still there go out" do
    post_comment("Will the cycle lanes reach Petone?")
    spam = post_comment("Cheap watches at example.biz")
    spam.destroy

    assert_emails(1) { perform_enqueued_jobs }
    assert_match "reach Petone", ActionMailer::Base.deliveries.last.body.to_s
  end
end
