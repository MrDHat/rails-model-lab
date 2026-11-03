require "test_helper"

class ToolSerialNormalizesTest < ActionDispatch::IntegrationTest
  def names = css_select("tbody tr td:first-child").map { _1.text.strip }

  test "the form stores serials stripped and upper case" do
    post tools_path, params: { tool: { name: "Sander", serial: "  sa-9 ", category_id: categories(:power).id } }
    assert_equal "SA-9", Tool.find_by!(name: "Sander").serial
    patch tool_path(tools(:trimmer)), params: { tool: { serial: "ht-002 " } }
    assert_equal "HT-002", tools(:trimmer).reload.serial
  end

  test "code stores them the same way" do
    tool = Tool.create!(name: "Rake", serial: " rk-1", category: categories(:garden))
    assert_equal "RK-1", tool.reload.serial
  end

  test "a differently typed serial clashes" do
    post tools_path, params: { tool: { name: "Drill", serial: " dr-001", category_id: categories(:power).id } }
    assert_response :unprocessable_entity
    assert_includes response.body, "Serial has already been taken"
    assert_not Tool.new(name: "Drill", serial: "Dr-001", category: categories(:power)).valid?
  end

  test "looks tools up by serial however it is typed" do
    get tools_path(serial: " dr-001 ")
    assert_equal ["Cordless drill"], names
    get tools_path(serial: "Ht-001")
    assert_equal ["Hedge trimmer"], names
  end
end
