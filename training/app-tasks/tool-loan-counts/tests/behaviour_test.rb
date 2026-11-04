require "test_helper"

class ToolLoanCountsTest < ActionDispatch::IntegrationTest
  setup do
    Loan.delete_all
    @saw = Tool.create!(name: "Mitre saw", serial: "MS-001", category: categories(:power), daily_fee_cents: 500)
  end

  def row(tool) = css_select("##{ActionView::RecordIdentifier.dom_id(tool)}").first&.text.to_s.squish

  def borrow(tool, member = members(:bo)) = tool.loans.create!(member: member, due_on: Date.current + 3).tap(&:return!)

  test "each row shows its total" do
    2.times { borrow(@saw) }
    borrow(tools(:drill))
    get tools_path
    assert_includes row(@saw), "Borrowed 2 times"
    assert_includes row(tools(:drill)), "Borrowed 1 time"
    assert_includes row(tools(:trimmer)), "Borrowed 0 times"
  end

  test "counts follow deleted and moved loans" do
    loans = Array.new(3) { borrow(@saw) }
    loans.first.destroy
    loans.second.update!(tool: tools(:trimmer))
    get tools_path
    assert_includes row(@saw), "Borrowed 1 time"
    assert_includes row(tools(:trimmer)), "Borrowed 1 time"
  end

  test "no count query per tool" do
    5.times { |i| borrow(Tool.create!(name: "Clamp #{i}", serial: "CL-#{i}", category: categories(:power))) }
    counts = 0
    counter = ->(*, payload) { counts += 1 if payload[:sql].match?(/COUNT\(/i) && payload[:sql].include?("loans") }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") { get tools_path }
    assert_response :success
    assert_operator counts, :<=, 1, "ran #{counts} loan count queries"
  end
end
