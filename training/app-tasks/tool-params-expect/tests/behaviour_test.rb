require "test_helper"

class ToolParamsTest < ActionDispatch::IntegrationTest
  def valid = { name: "Ladder", serial: "LD-001", category_id: categories(:garden).id, daily_fee_cents: 100 }

  test "junk on create is a bad request and creates nothing" do
    [{ tool: "hello" }, {}, { tool: ["x"] }, { name: "Ladder" }].each do |params|
      assert_no_difference("Tool.count") { post tools_path, params: params }
      assert_response :bad_request, "for #{params.inspect}"
    end
  end

  test "junk on update is a bad request and changes nothing" do
    [{ tool: "hello" }, {}, { tool: ["x"] }].each do |params|
      patch tool_path(tools(:drill)), params: params
      assert_response :bad_request, "for #{params.inspect}"
    end
    assert_equal "Cordless drill", tools(:drill).reload.name
  end

  test "normal submissions still work" do
    post tools_path, params: { tool: valid }
    tool = Tool.find_by!(serial: "LD-001")
    assert_redirected_to tool_path(tool)
    patch tool_path(tool), params: { tool: { name: "Tall ladder" } }
    assert_redirected_to tool_path(tool)
    assert_equal "Tall ladder", tool.reload.name
  end

  test "validation failures still re-render the form" do
    post tools_path, params: { tool: valid.merge(name: "") }
    assert_response :unprocessable_entity
    patch tool_path(tools(:drill)), params: { tool: { serial: "" } }
    assert_response :unprocessable_entity
  end

  test "unknown fields are still ignored" do
    post tools_path, params: { tool: valid.merge(retired_at: Time.current, id: 999) }
    tool = Tool.find_by!(serial: "LD-001")
    assert_nil tool.retired_at
    refute_equal 999, tool.id
  end
end
