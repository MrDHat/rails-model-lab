require "test_helper"

class LoanReturnLockTest < ActiveSupport::TestCase
  setup do
    Loan.delete_all
    travel_to Time.utc(2026, 5, 4, 10)
    @loan = tools(:drill).loans.create!(member: members(:bo), due_on: Date.current + 7)
  end

  teardown { travel_back }

  test "an open loan is charged per day" do
    @loan.return!(at: Time.utc(2026, 5, 7, 9))
    assert_equal 900, @loan.reload.fee_cents
  end

  test "a stale copy of the loan does not charge again" do
    first = Loan.find(@loan.id)
    second = Loan.find(@loan.id)
    first.return!(at: Time.utc(2026, 5, 6, 9))
    second.return!(at: Time.utc(2026, 5, 9, 9))
    @loan.reload
    assert_equal Time.utc(2026, 5, 6, 9), @loan.returned_at
    assert_equal 600, @loan.fee_cents
  end

  test "returning a returned loan changes nothing" do
    @loan.return!(at: Time.utc(2026, 5, 6, 9))
    assert_no_changes -> { @loan.reload.attributes } do
      Loan.find(@loan.id).return!(at: Time.utc(2026, 5, 8, 9))
    end
  end
end
