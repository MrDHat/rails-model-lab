class LoanMailer < ApplicationMailer
  def overdue(loan)
    @loan = loan
    mail to: loan.member.email, subject: "#{loan.tool.name} was due #{loan.due_on.to_fs(:long)}"
  end
end
