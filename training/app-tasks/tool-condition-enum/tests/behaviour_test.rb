require "test_helper"

class ToolConditionEnumTest < ActionDispatch::IntegrationTest
  def names = css_select("tbody tr td:first-child").map { _1.text.strip }

  test "new tools are good" do
    tool = Tool.create!(name: "Sander", serial: "SA-1", category: categories(:power))
    assert_equal "good", tool.reload.condition
  end

  test "the form changes the condition" do
    patch tool_path(tools(:trimmer)), params: { tool: { condition: "worn" } }
    assert_redirected_to tool_path(tools(:trimmer))
    assert_equal "worn", tools(:trimmer).reload.condition
    get edit_tool_path(tools(:trimmer))
    assert_select "select[name='tool[condition]'] option[selected]", text: "worn"
  end

  test "an unknown condition is a validation error" do
    patch tool_path(tools(:trimmer)), params: { tool: { condition: "shiny" } }
    assert_response :unprocessable_entity
    assert_equal "good", tools(:trimmer).reload.condition
    post tools_path, params: { tool: { name: "Sander", serial: "SA-1", category_id: categories(:power).id, condition: "new" } }
    assert_response :unprocessable_entity
    assert_not Tool.exists?(serial: "SA-1")
  end

  test "broken tools can't be borrowed" do
    tools(:trimmer).update!(condition: "broken")
    sign_in members(:bo)
    post tool_loans_path(tools(:trimmer)), params: { due_on: Date.current + 2 }
    assert_equal "Tool is broken", flash[:alert]
    assert_empty tools(:trimmer).loans
    tools(:trimmer).update!(condition: "worn")
    post tool_loans_path(tools(:trimmer)), params: { due_on: Date.current + 2 }
    assert_equal 1, tools(:trimmer).loans.count
  end

  test "the list filters by condition" do
    tools(:trimmer).update!(condition: "worn")
    get tools_path(condition: "worn")
    assert_equal ["Hedge trimmer"], names
    get tools_path(condition: "good")
    assert_equal ["Cordless drill"], names
    get tools_path(condition: "broken")
    assert_empty names
    get tools_path(condition: "lost")
    assert_equal 2, names.size
  end
end
