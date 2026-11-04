require "test_helper"

class ToolNameUniquePerCategoryTest < ActionDispatch::IntegrationTest
  def build(name, category) = Tool.new(name: name, serial: SecureRandom.hex(4), category: category)

  test "the same name in the same category clashes, ignoring case" do
    tool = build("cordless DRILL", categories(:power))
    assert_not tool.save
    assert_equal ["Name is already used in this category"], tool.errors.full_messages
  end

  test "the same name in another category is fine" do
    assert build("Cordless drill", categories(:garden)).save
  end

  test "a tool doesn't clash with itself" do
    assert tools(:drill).update(name: "CORDLESS DRILL")
  end

  test "the form shows the error" do
    post tools_path, params: { tool: { name: "Hedge Trimmer", serial: "HT-002", category_id: categories(:garden).id } }
    assert_response :unprocessable_entity
    assert_includes response.body, "Name is already used in this category"
    patch tool_path(tools(:drill)), params: { tool: { name: "hedge trimmer", category_id: categories(:garden).id } }
    assert_response :unprocessable_entity
  end
end
