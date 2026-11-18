require "test_helper"

class LetterMailerTest < ActionMailer::TestCase
  test "the desk gets the letter and can reply to the writer" do
    mail = LetterMailer.received(letters(:bus_timetable))
    assert_equal ["letters@gazette.example"], mail.to
    assert_equal ["june.hart@example.com"], mail.reply_to
    assert_equal "Letter: The new bus timetable", mail.subject
    assert_match "June Hart, Petone", mail.body.to_s
  end

  test "the writer gets an acknowledgement from the letters desk" do
    mail = LetterMailer.acknowledgement(letters(:bus_timetable))
    assert_equal ["june.hart@example.com"], mail.to
    assert_equal ["letters@gazette.example"], mail.from
    assert_match "Dear June Hart", mail.body.to_s
  end
end
