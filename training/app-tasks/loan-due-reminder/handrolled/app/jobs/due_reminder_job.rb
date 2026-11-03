class DueReminderJob < ApplicationJob
  queue_as :default

  def perform(loan)
    LoanMailer.due_soon(loan).deliver_now
  end
end
