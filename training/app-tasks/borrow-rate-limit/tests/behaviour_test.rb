require "test_helper"

class BorrowRateLimitTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
    Loan.delete_all
    @tools = Array.new(8) { |i| Tool.create!(name: "Clamp #{i}", serial: "CL-#{i}", category: categories(:power)) }
  end

  def attempt(tool) = post(tool_loans_path(tool), params: { due_on: Date.current + 2 })

  test "the sixth attempt in a minute is refused and borrows nothing" do
    travel_to Time.utc(2026, 5, 4, 10, 0, 5) do
      sign_in members(:bo)
      5.times { attempt(@tools[_1]) }
      assert_equal 5, members(:bo).loans.count
      attempt(@tools[5])
      assert_response :too_many_requests
      assert_includes response.body, "Too many borrow attempts, try again in a minute"
      assert_equal 5, members(:bo).loans.count
    end
  end

  test "failed attempts count too" do
    travel_to Time.utc(2026, 5, 4, 10, 0, 5) do
      sign_in members(:bo)
      5.times { attempt(tools(:drill)) }
      attempt(@tools[0])
      assert_response :too_many_requests
    end
  end

  test "other members on the same address are not affected" do
    travel_to Time.utc(2026, 5, 4, 10, 0, 5) do
      sign_in members(:bo)
      6.times { attempt(@tools[_1]) }
      assert_response :too_many_requests
      sign_in members(:ana)
      attempt(@tools[6])
      assert_redirected_to tool_path(@tools[6])
      assert_equal 1, members(:ana).loans.where(tool: @tools[6]).count
    end
  end

  test "the limit lifts after a minute" do
    sign_in members(:bo)
    travel_to(Time.utc(2026, 5, 4, 10, 0, 5)) { 6.times { attempt(@tools[_1]) } }
    assert_equal 5, members(:bo).loans.count
    travel_to(Time.utc(2026, 5, 4, 10, 1, 30)) { attempt(@tools[6]) }
    assert_redirected_to tool_path(@tools[6])
  end

  test "returning is not limited" do
    travel_to Time.utc(2026, 5, 4, 10, 0, 5) do
      sign_in members(:bo)
      5.times { attempt(@tools[_1]) }
      members(:bo).loans.open.each { patch return_loan_path(_1) }
      assert_equal 0, members(:bo).loans.open.count
    end
  end
end
