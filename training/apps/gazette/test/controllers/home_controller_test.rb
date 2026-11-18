require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "front page shows the lead and the sections" do
    get root_path
    assert_response :success
    assert_select ".lead h1", "Harbour Bridge tolls to rise in March"
    assert_select ".front-section", 4
    assert_select "#section-sport .teaser h3", "Harbour Hawks win the provincial final"
    assert_select "body", text: /Ferry crews/, count: 0
  end
end
