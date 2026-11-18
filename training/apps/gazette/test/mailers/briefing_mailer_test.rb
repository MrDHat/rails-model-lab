require "test_helper"

class BriefingMailerTest < ActionMailer::TestCase
  test "lists the stories with links and Wellington's date" do
    mail = BriefingMailer.morning(readers(:sam), [articles(:rugby_final)])
    assert_equal ["sam@example.com"], mail.to
    assert_equal "Your Harbour Gazette briefing for September 14, 2026", mail.subject
    assert_match "Good morning Sam I", mail.body.to_s
    assert_match "http://example.com/articles/hawks-win-provincial-final", mail.body.to_s
  end
end
