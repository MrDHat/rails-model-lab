require "test_helper"

class ToolsControllerTest < ActionDispatch::IntegrationTest
  test "lists tools in service" do
    tools(:trimmer).update!(retired_at: Time.current)
    get tools_path
    assert_response :success
    assert_select "td", text: "Cordless drill"
    assert_select "td", text: "Hedge trimmer", count: 0
  end

  test "creates a tool" do
    post tools_path, params: { tool: { name: "Ladder", serial: "LD-001", category_id: categories(:garden).id, daily_fee_cents: 100 } }
    assert_redirected_to tool_path(Tool.find_by!(serial: "LD-001"))
  end
end
