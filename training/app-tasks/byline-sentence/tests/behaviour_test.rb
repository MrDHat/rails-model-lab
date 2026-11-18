require "test_helper"

class BylineSentenceTest < ActionDispatch::IntegrationTest
  def reorder(article, *authors)
    authors.each_with_index do |author, position|
      Authorship.find_or_create_by!(article: article, author: author).update_columns(position: position)
    end
  end

  test "two names are joined with and, in byline order" do
    assert_equal "By Eli Moana and Hana Reti", articles(:harbour_bridge).byline
    reorder articles(:harbour_bridge), authors(:hana), authors(:eli)
    assert_equal "By Hana Reti and Eli Moana", Article.find(articles(:harbour_bridge).id).byline
  end

  test "three or more have commas and a final and, without the serial comma" do
    reorder articles(:harbour_bridge), authors(:hana), authors(:tom), authors(:eli)
    assert_equal "By Hana Reti, Tom Bell and Eli Moana", Article.find(articles(:harbour_bridge).id).byline
    reorder articles(:harbour_bridge), authors(:eli), authors(:priya), authors(:tom), authors(:hana)
    assert_equal "By Eli Moana, Priya Nair, Tom Bell and Hana Reti", Article.find(articles(:harbour_bridge).id).byline
  end

  test "one name stays as it is" do
    assert_equal "By Tom Bell", articles(:rugby_final).byline
  end

  test "pages and the API use the same byline" do
    reorder articles(:harbour_bridge), authors(:hana), authors(:eli)

    get article_path(articles(:harbour_bridge))
    assert_select ".byline", "By Hana Reti and Eli Moana"
    get section_path(sections(:news))
    assert_select "#article_#{articles(:harbour_bridge).id} .meta", /\ABy Hana Reti and Eli Moana ·/
    get api_articles_path(section: "news"), headers: api_headers, as: :json
    assert_equal "By Hana Reti and Eli Moana", response.parsed_body.first["byline"]
  end
end
