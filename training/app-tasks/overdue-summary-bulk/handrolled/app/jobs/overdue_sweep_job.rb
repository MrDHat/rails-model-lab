# Runs nightly: emails every member with an overdue loan.
class OverdueSweepJob < ApplicationJob
  queue_as :default

  def perform
    Member.where(id: Loan.overdue.select(:member_id)).find_each do |member|
      LoanMailer.overdue_summary(member).deliver_later
    end
  end
end
