require "test_helper"

class LoansControllerTest < ActionDispatch::IntegrationTest
  test "a signed-in member borrows and returns a tool" do
    sign_in members(:bo)
    post tool_loans_path(tools(:trimmer)), params: { due_on: Date.current + 2 }
    assert_redirected_to tool_path(tools(:trimmer))
    loan = members(:bo).loans.open.last
    patch return_loan_path(loan)
    assert loan.reload.returned_at
  end

  test "borrowing needs a signed-in member" do
    post tool_loans_path(tools(:trimmer))
    assert_redirected_to new_session_path
  end
end
