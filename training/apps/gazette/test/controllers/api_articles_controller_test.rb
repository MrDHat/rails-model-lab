require "test_helper"

class ApiArticlesControllerTest < ActionDispatch::IntegrationTest
  test "needs a reader token" do
    get api_articles_path, as: :json
    assert_response :unauthorized
    get api_articles_path, headers: { "Authorization" => "Bearer nope" }, as: :json
    assert_response :unauthorized
  end

  test "lists live stories, newest first" do
    get api_articles_path, headers: api_headers, as: :json
    assert_response :success
    slugs = response.parsed_body.pluck("slug")
    assert_equal %w[harbour-bridge-tolls-to-rise hawks-win-provincial-final council-budget-library-hours
                    port-profits-climb waterfront-needs-more-cafes], slugs
    story = response.parsed_body.first
    assert_equal "News", story["section"]
    assert_equal %w[council transport], story["tags"].sort
    assert_equal 2, story["comments_count"]
  end

  test "filters by section and tag" do
    get api_articles_path(section: "news"), headers: api_headers, as: :json
    assert_equal 2, response.parsed_body.size
    get api_articles_path(tag: "budget"), headers: api_headers, as: :json
    assert_equal %w[council-budget-library-hours port-profits-climb], response.parsed_body.pluck("slug")
  end

  test "syncs stories changed since a time, oldest change first" do
    get api_articles_path(updated_since: "2026-09-13T08:00:00+12:00"), headers: api_headers, as: :json
    assert_equal %w[council-budget-library-hours hawks-win-provincial-final harbour-bridge-tolls-to-rise],
                 response.parsed_body.pluck("slug")
  end

  test "bad sync times are a bad request" do
    get api_articles_path(updated_since: "yesterday"), headers: api_headers, as: :json
    assert_response :bad_request
  end

  test "shows a story with its body and corrections" do
    get api_article_path(articles(:council_budget)), headers: api_headers, as: :json
    assert_response :success
    assert_match "library hours", response.parsed_body["body"]
    assert_equal 1, response.parsed_body["corrections"].size
  end

  test "drafts are not found" do
    get api_article_path(articles(:ferry_strike)), headers: api_headers, as: :json
    assert_response :not_found
  end

  test "lists sections" do
    get api_sections_path, headers: api_headers, as: :json
    assert_equal %w[business news opinion sport wire], response.parsed_body.pluck("slug")
  end
end
