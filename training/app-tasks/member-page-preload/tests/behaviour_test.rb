require "test_helper"

class MemberPagePreloadTest < ActionDispatch::IntegrationTest
  setup { Loan.delete_all }

  def lend(count)
    count.times do |i|
      category = Category.create!(name: "Shelf #{SecureRandom.hex(3)}")
      tool = Tool.create!(name: "Tool #{SecureRandom.hex(3)}", serial: SecureRandom.hex(4), category: category)
      tool.loans.create!(member: members(:bo), due_on: Date.current + i).return!
    end
  end

  def queries_for_member_page
    count = 0
    counter = ->(*, payload) { count += 1 unless payload[:name].in?(["SCHEMA", "TRANSACTION"]) || payload[:cached] }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") { get member_path(members(:bo)) }
    assert_response :success
    count
  end

  test "shows each tool with its category" do
    tools(:drill).loans.create!(member: members(:bo), due_on: Date.new(2026, 7, 1))
    get member_path(members(:bo))
    assert_select "li", text: /Cordless drill \(Power tools\), due July 01, 2026/
  end

  test "the query count does not grow with the loans" do
    lend(2)
    few = queries_for_member_page
    lend(8)
    assert_equal few, queries_for_member_page
    assert_select "li", 10
  end
end
