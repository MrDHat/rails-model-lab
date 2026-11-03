# Runs nightly: emails every member with an overdue loan.
class OverdueSweepJob < ApplicationJob
  queue_as :default

  def perform
    Member.where(id: Loan.overdue.select(:member_id)).in_batches(of: 1000) do |members|
      ActionMailer.deliver_all_later(*members.map { LoanMailer.overdue_summary(_1) })
    end
  end
end
