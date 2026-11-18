require "test_helper"

class CommentMailerTest < ActionMailer::TestCase
  test "awaiting moderation goes to every author with the comment" do
    mail = CommentMailer.awaiting_moderation(comments(:harbour_sam))
    assert_equal %w[eli.moana@gazette.example hana.reti@gazette.example], mail.to.sort
    assert_equal "New comment on \"Harbour Bridge tolls to rise in March\"", mail.subject
    assert_match "Another tax on people who drive to work.", mail.body.to_s
    assert_match "http://example.com/newsroom/comments", mail.body.to_s
  end
end
