require "test_helper"
require_relative "app_calls"

class LettersEmailNamesApiTest < ActionMailer::TestCase
  test "addresses are built with email_address_with_name" do
    LetterMailer.received(letters(:bus_timetable)).message
    LetterMailer.acknowledgement(letters(:bus_timetable)).message
    assert_includes AnswerCalls.names, :email_address_with_name
  end
end
