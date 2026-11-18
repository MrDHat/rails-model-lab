require "test_helper"

class FrontPageOrderTest < ActionDispatch::IntegrationTest
  setup { sign_in_editor editors(:grace) }

  def order_front_page(list)
    patch newsroom_settings_path, params: { settings: { front_page_order: list } }
    assert_redirected_to edit_newsroom_settings_path
  end

  def front_sections
    get root_path
    css_select(".front-section h2").map(&:text)
  end

  test "listed sections come first, in order, then the rest alphabetically" do
    order_front_page "news, sport, business"
    assert_equal %w[News Sport Business Opinion], front_sections
  end

  test "unknown slugs and stray spaces are ignored" do
    order_front_page " sport,lifestyle ,  news"
    assert_equal %w[Sport News Business Opinion], front_sections
  end

  test "an empty list means alphabetical" do
    order_front_page "opinion"
    assert_equal %w[Opinion Business News Sport], front_sections
    order_front_page ""
    assert_equal %w[Business News Opinion Sport], front_sections
  end

  test "the settings page shows the current order" do
    order_front_page "news,sport"
    get edit_newsroom_settings_path
    assert_select "input[name='settings[front_page_order]'][value='news, sport']"
  end
end
