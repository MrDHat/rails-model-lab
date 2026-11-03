require "test_helper"

class ToolSearchLikeTest < ActionDispatch::IntegrationTest
  setup do
    ["Socket set 3_8", "Socket set 308", "Clamp 50%", "Clamp 500", "Back\\saw"].each_with_index do |name, i|
      Tool.create!(name: name, serial: "S-#{i}", category: categories(:power))
    end
  end

  def names = css_select("tbody tr td:first-child").map { _1.text.strip }

  test "matches part of the name, ignoring case" do
    get tools_path(q: "CLAMP")
    assert_equal ["Clamp 50%", "Clamp 500"], names
    get tools_path(q: "drill")
    assert_equal ["Cordless drill"], names
  end

  test "underscore and percent match themselves" do
    get tools_path(q: "3_8")
    assert_equal ["Socket set 3_8"], names
    get tools_path(q: "50%")
    assert_equal ["Clamp 50%"], names
    get tools_path(q: "%")
    assert_equal ["Clamp 50%"], names
  end

  test "a backslash matches itself" do
    get tools_path(q: "k\\s")
    assert_equal ["Back\\saw"], names
  end

  test "no search lists everything" do
    get tools_path(q: " ")
    assert_equal 7, names.size
    get tools_path
    assert_equal 7, names.size
  end
end
