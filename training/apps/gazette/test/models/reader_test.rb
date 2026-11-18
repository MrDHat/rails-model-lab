require "test_helper"

class ReaderTest < ActiveSupport::TestCase
  test "new readers get an API token" do
    reader = Reader.create!(email: " Kai@Example.com ", display_name: "Kai")
    assert reader.api_token.present?
    assert_equal "kai@example.com", reader.email
  end

  test "emails are unique and must look like emails" do
    assert_not Reader.new(email: "MERE@example.com", display_name: "M").valid?
    assert_not Reader.new(email: "not an email", display_name: "M").valid?
  end

  test "deleting a reader keeps their letters" do
    reader = readers(:lou)
    letter = Letter.create!(reader: reader, name: "Lou Park", email: "lou@example.com", subject: "Hi", body: "Hello")
    reader.destroy
    assert_nil letter.reload.reader_id
  end

  test "search by email or name" do
    assert_equal [readers(:sam)], Reader.search("sam@").to_a
    assert_equal [readers(:mere)], Reader.search("Mere").to_a
  end
end
