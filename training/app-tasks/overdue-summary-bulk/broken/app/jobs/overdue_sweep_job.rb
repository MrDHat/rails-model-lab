# Runs nightly: emails every member with an overdue loan.
class OverdueSweepJob < ApplicationJob
  queue_as :default

  def perform
    Loan.overdue.includes(:member).find_in_batches(batch_size: 1000) do |loans|
      ActionMailer.deliver_all_later(*loans.map { LoanMailer.overdue_summary(_1.member) })
    end
  end
end
