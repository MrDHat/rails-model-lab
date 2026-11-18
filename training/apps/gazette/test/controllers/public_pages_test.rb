require "test_helper"

class PublicPagesTest < ActionDispatch::IntegrationTest
  test "section pages list live stories, newest first" do
    get section_path(sections(:news))
    assert_response :success
    assert_select ".teaser h3", count: 2
    assert_select ".teaser:first-of-type h3", "Harbour Bridge tolls to rise in March"
  end

  test "unknown sections are not found" do
    get section_path("lifestyle")
    assert_response :not_found
  end

  test "tag pages" do
    get tag_path(tags(:budget))
    assert_select ".teaser h3", count: 2
  end

  test "author pages list their published stories" do
    get author_path(authors(:hana))
    assert_select "h1", "Hana Reti"
    assert_select ".teaser h3", count: 2
  end

  test "search finds live stories only" do
    get search_path(q: "ferry")
    assert_select ".result", 0
    get search_path(q: "cycle")
    assert_select ".result", 1
  end

  test "readers can write to the editor" do
    get new_letter_path
    assert_response :success
    assert_difference("Letter.count") do
      post letters_path, params: { letter: { name: "Ana Lima", email: "ana@example.com", town: "Eastbourne",
                                             subject: "Ferry fares", body: "Too high." } }
    end
    assert_redirected_to letters_thanks_path
    assert Letter.last.received?
  end

  test "incomplete letters show the form again" do
    post letters_path, params: { letter: { name: "Ana Lima", email: "ana@example.com", subject: "", body: "" } }
    assert_response :unprocessable_entity
    assert_select ".errors li", minimum: 2
  end
end
