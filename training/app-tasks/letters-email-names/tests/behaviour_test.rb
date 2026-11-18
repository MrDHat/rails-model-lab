require "test_helper"

class LettersEmailNamesTest < ActionMailer::TestCase
  def letter(name) = Letter.new(name: name, email: "writer@example.com", subject: "Buses", body: "Late again.")

  # As the recipient's mail client will read it.
  def delivered(mail) = Mail.new(mail.encoded)

  test "the desk can reply to the writer by name" do
    mail = delivered(LetterMailer.received(letters(:bus_timetable)))
    assert_equal ["june.hart@example.com"], mail.reply_to
    assert_equal ["June Hart"], mail[:reply_to].display_names
    assert_equal ["letters@gazette.example"], mail.to
  end

  test "the acknowledgement is addressed by name, from the letters desk" do
    mail = delivered(LetterMailer.acknowledgement(letters(:bus_timetable)))
    assert_equal ["june.hart@example.com"], mail.to
    assert_equal ["June Hart"], mail[:to].display_names
    assert_equal ["letters@gazette.example"], mail.from
    assert_equal ["Harbour Gazette letters desk"], mail[:from].display_names
  end

  test "names with commas, quotes and accents survive" do
    ["Hart, June", %(Te Rangi "Bub" Wiremu), "Zoë Māhina", "O'Brien (Petone)"].each do |name|
      received = delivered(LetterMailer.received(letter(name)))
      assert_equal ["writer@example.com"], received.reply_to, name
      assert_equal [name], received[:reply_to].display_names

      acknowledgement = delivered(LetterMailer.acknowledgement(letter(name)))
      assert_equal ["writer@example.com"], acknowledgement.to, name
      assert_equal [name], acknowledgement[:to].display_names
    end
  end
end
