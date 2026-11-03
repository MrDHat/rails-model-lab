# Runs nightly: emails every member with an overdue loan.
class OverdueSweepJob < ApplicationJob
  queue_as :default

  def perform
    Loan.overdue.includes(:member, :tool).find_each do |loan|
      LoanMailer.overdue(loan).deliver_later
    end
  end
end
