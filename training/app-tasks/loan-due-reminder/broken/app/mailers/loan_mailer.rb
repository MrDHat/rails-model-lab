class LoanMailer < ApplicationMailer
  def overdue(loan)
    @loan = loan
    mail to: loan.member.email, subject: "#{loan.tool.name} was due #{loan.due_on.to_fs(:long)}"
  end

  def due_soon(loan)
    return if loan.returned_at

    @loan = loan
    mail to: loan.member.email, subject: "Reminder: #{loan.tool.name} is due back #{loan.due_on.to_fs(:long)}"
  end
end
