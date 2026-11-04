require "test_helper"

class ToolsBulkImportTest < ActionDispatch::IntegrationTest
  def import(rows)
    inserts = 0
    counter = ->(*, payload) { inserts += 1 if payload[:sql].match?(/\A\s*INSERT INTO "?tools"?/i) }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") do
      post import_tools_path, params: { tools: rows }, as: :json
    end
    assert_response :success
    [response.parsed_body["imported"], inserts]
  end

  test "imports every new tool in one insert" do
    rows = Array.new(40) { { name: "Clamp #{_1}", serial: "CL-#{_1}", category: "Power tools", daily_fee_cents: 50 + _1 } }
    imported, inserts = import(rows)
    assert_equal 40, imported
    assert_equal 1, inserts
    clamp = Tool.find_by!(serial: "CL-7")
    assert_equal ["Clamp 7", categories(:power), 57], [clamp.name, clamp.category, clamp.daily_fee_cents]
    assert_in_delta Time.current, clamp.created_at, 60
    assert_in_delta Time.current, clamp.updated_at, 60
  end

  test "skips taken serials and unknown categories" do
    rows = [
      { name: "Rake", serial: "RK-1", category: "Garden", daily_fee_cents: 100 },
      { name: "Drill again", serial: "DR-001", category: "Power tools", daily_fee_cents: 100 },
      { name: "Kayak", serial: "KY-1", category: "Boats", daily_fee_cents: 900 }
    ]
    imported, inserts = import(rows)
    assert_equal 1, imported
    assert_operator inserts, :<=, 1
    assert_equal "Cordless drill", Tool.find_by!(serial: "DR-001").name
    assert_not Tool.exists?(serial: "KY-1")
    assert_equal categories(:garden), Tool.find_by!(serial: "RK-1").category
  end
end
