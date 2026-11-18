require "test_helper"

class SectionRenameTouchTest < ActionDispatch::IntegrationTest
  def rename(section, name)
    sign_in_editor editors(:owen)
    patch newsroom_section_path(section), params: { section: { name: name } }
    assert_redirected_to newsroom_sections_path
  end

  test "story pages show the new name to repeat visitors" do
    get article_path(articles(:harbour_bridge))
    etag = response.headers["ETag"]
    travel 1.minute
    rename sections(:news), "Local news"
    delete newsroom_session_path

    get article_path(articles(:harbour_bridge)), headers: { "If-None-Match" => etag }
    assert_response :success
    assert_select ".kicker", "Local news"
  end

  test "the app's sync picks the stories up" do
    travel 1.minute
    since = Time.current.iso8601
    get api_articles_path(updated_since: since), headers: api_headers, as: :json
    assert_empty response.parsed_body

    travel 1.minute
    rename sections(:news), "Local news"
    get api_articles_path(updated_since: since), headers: api_headers, as: :json
    assert_equal %w[council-budget-library-hours harbour-bridge-tolls-to-rise], response.parsed_body.pluck("slug").sort
    assert_equal ["Local news"], response.parsed_body.pluck("section").uniq
  end

  test "stories in other sections are left alone" do
    before = articles(:rugby_final).updated_at
    travel 1.minute
    rename sections(:news), "Local news"
    assert_equal before, articles(:rugby_final).reload.updated_at
    assert_equal Time.current, articles(:ferry_strike).reload.updated_at
  end
end
