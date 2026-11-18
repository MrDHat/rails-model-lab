require "test_helper"

class CommentAlertJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "new comments email the story's authors" do
    Comment.create!(article: articles(:harbour_bridge), reader: readers(:lou), body: "Where will the lanes go?")
    assert_emails(1) { perform_enqueued_jobs(only: CommentAlertJob) }
    assert_equal %w[eli.moana@gazette.example hana.reti@gazette.example], ActionMailer::Base.deliveries.last.to.sort
  end

  test "no email when the comment was moderated before the job ran" do
    comment = Comment.create!(article: articles(:harbour_bridge), reader: readers(:lou), body: "Where will the lanes go?")
    comment.approved!
    assert_no_emails { perform_enqueued_jobs(only: CommentAlertJob) }
  end
end
