require "test_helper"

class MemberBanReturnsTransactionTest < ActiveSupport::TestCase
  # Lets a test make one loan's return fail.
  module FailingReturn
    mattr_accessor :failing_id

    def return!(...)
      raise ActiveRecord::RecordNotSaved, "till jammed" if id == FailingReturn.failing_id
      super
    end
  end
  Loan.prepend(FailingReturn)

  setup do
    FailingReturn.failing_id = nil
    Loan.delete_all
    travel_to Time.utc(2026, 5, 1, 9)
    @rake = Tool.create!(name: "Rake", serial: "RK-1", category: categories(:garden), daily_fee_cents: 100)
    @done = tools(:drill).loans.create!(member: members(:ana), due_on: Date.current + 1).tap { _1.update_columns(returned_at: 1.day.ago) }
    @loans = [tools(:drill), tools(:trimmer), @rake].map { _1.loans.create!(member: members(:bo), due_on: Date.current + 9) }
    travel_to Time.utc(2026, 5, 4, 15)
  end

  teardown { travel_back }

  test "banning returns the open loans at the moment of the ban" do
    members(:bo).ban!
    assert members(:bo).reload.banned?
    @loans.each(&:reload)
    assert @loans.all? { _1.returned_at == Time.utc(2026, 5, 4, 15) }
    assert_equal [900, 750, 300], @loans.map(&:fee_cents)
  end

  test "a failing return undoes the whole ban" do
    FailingReturn.failing_id = @loans.second.id
    assert_raises(ActiveRecord::RecordNotSaved) { members(:bo).ban! }
    assert_not members(:bo).reload.banned?
    @loans.each(&:reload)
    assert @loans.all? { _1.returned_at.nil? && _1.fee_cents.nil? }
  end

  test "a member without loans is just banned" do
    members(:ana).ban!
    assert members(:ana).reload.banned?
  end
end
