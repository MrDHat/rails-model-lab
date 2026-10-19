require "test_helper"

class ExpenseClaimsTest < ActionDispatch::IntegrationTest
  test "create read and edit a draft" do
    post "/expense_claims", params: { expense_claim: { status: "draft" } }, as: :json
    assert_response :created
    id = response.parsed_body.fetch("id")
    get "/expense_claims/#{id}", as: :json
    assert_response :ok
    assert_equal "draft", response.parsed_body.fetch("status")
    patch "/expense_claims/#{id}", params: { expense_claim: { merchant: "Cafe" } }, as: :json
    assert_response :ok
    assert_equal "Cafe", ExpenseClaim.find(id).merchant
  end

  test "unknown status is rejected" do
    assert_no_difference "ExpenseClaim.count" do
      post "/expense_claims", params: { expense_claim: { status: "unknown" } }, as: :json
    end
    assert_response :unprocessable_entity
    assert response.parsed_body.fetch("errors").present?
  end

  test "missing claims return not found" do
    get "/expense_claims/99999", as: :json
    assert_response :not_found
    patch "/expense_claims/99999", params: { expense_claim: { merchant: "Cafe" } }, as: :json
    assert_response :not_found
  end
end
