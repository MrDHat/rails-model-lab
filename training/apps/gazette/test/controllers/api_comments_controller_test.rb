require "test_helper"

class ApiCommentsControllerTest < ActionDispatch::IntegrationTest
  test "readers see approved comments and their own pending ones" do
    get api_article_comments_path(articles(:harbour_bridge)), headers: api_headers(:sam), as: :json
    assert_equal ["About time we had proper cycle lanes.", "Another tax on people who drive to work."],
                 response.parsed_body.pluck("body")
    get api_article_comments_path(articles(:harbour_bridge)), headers: api_headers(:lou), as: :json
    assert_equal ["About time we had proper cycle lanes."], response.parsed_body.pluck("body")
  end

  test "posting a comment" do
    assert_difference -> { articles(:council_budget).reload.comments_count }, 1 do
      post api_article_comments_path(articles(:council_budget)), params: { comment: { body: "Good." } },
           headers: api_headers(:lou), as: :json
    end
    assert_response :created
    assert_equal ["pending", "Lou P"], response.parsed_body.values_at("status", "reader")
  end

  test "invalid comments are a 422" do
    post api_article_comments_path(articles(:council_budget)), params: { comment: { body: "What a scam" } },
         headers: api_headers(:lou), as: :json
    assert_response :unprocessable_entity
    assert_equal ["Body contains words we don't publish"], response.parsed_body["errors"]
  end

  test "no comments on drafts" do
    post api_article_comments_path(articles(:ferry_strike)), params: { comment: { body: "Hi" } },
         headers: api_headers(:lou), as: :json
    assert_response :not_found
  end
end
