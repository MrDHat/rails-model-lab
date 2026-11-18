require "test_helper"

class LetterTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "new letters notify the desk and the writer" do
    assert_enqueued_emails 2 do
      Letter.create!(name: "Ana Lima", email: "ana@example.com", subject: "Parking", body: "There is none.")
    end
  end

  test "signature includes the town when given" do
    assert_equal "June Hart, Petone", letters(:bus_timetable).signature
    assert_equal "Ana Lima", Letter.new(name: "Ana Lima").signature
  end

  test "needs a subject and a body" do
    letter = Letter.new(name: "Ana", email: "ana@example.com")
    assert_not letter.valid?
    assert letter.errors.of_kind?(:subject, :blank)
    assert letter.errors.of_kind?(:body, :blank)
  end
end
