require "test_helper"

class LoanTest < ActiveSupport::TestCase
  test "a tool on loan can't be borrowed again" do
    loan = Loan.new(member: members(:bo), tool: tools(:drill), due_on: Date.current + 1)
    assert_not loan.valid?
    assert_includes loan.errors[:tool], "is already on loan"
  end

  test "banned members can't borrow" do
    members(:bo).ban!
    loan = Loan.new(member: members(:bo), tool: tools(:trimmer), due_on: Date.current + 1)
    assert_not loan.valid?
  end

  test "returning charges the daily fee for each day, at least one" do
    loan = loans(:ana_drill)
    loan.return!(at: loan.created_at + 2.days)
    assert_equal 600, loan.fee_cents
  end
end
