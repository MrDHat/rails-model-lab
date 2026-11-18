require "test_helper"

class CleanLanguageValidatorTest < ActionDispatch::IntegrationTest
  def send_letter(subject, body)
    post letters_path, params: { letter: { name: "Ana Lima", email: "ana@example.com", subject: subject, body: body } }
  end

  test "letters with banned words come back with a message on the field" do
    assert_no_difference("Letter.count") { send_letter "Ferry fares", "The operator is a Crook." }
    assert_response :unprocessable_entity
    assert_select ".errors li", "Body contains words we don't publish"

    send_letter "SCAM alert", "Ferry fares are too high."
    assert_response :unprocessable_entity
    assert_select ".errors li", "Subject contains words we don't publish"
  end

  test "words that only contain a banned word are fine" do
    assert_difference("Letter.count") { send_letter "Scampi", "The crooked path to the beach needs fixing." }
  end

  test "comments catch any capitalisation" do
    post api_article_comments_path(articles(:council_budget)), params: { comment: { body: "What an IDIOT" } },
         headers: api_headers(:lou), as: :json
    assert_response :unprocessable_entity
    assert_equal ["Body contains words we don't publish"], response.parsed_body["errors"]

    comment = Comment.new(article: articles(:council_budget), reader: readers(:lou), body: "Moron.")
    assert_not comment.valid?
  end
end
