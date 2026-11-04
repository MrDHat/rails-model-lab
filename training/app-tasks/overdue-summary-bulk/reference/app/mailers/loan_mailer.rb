class LoanMailer < ApplicationMailer
  def overdue(loan)
    @loan = loan
    mail to: loan.member.email, subject: "#{loan.tool.name} was due #{loan.due_on.to_fs(:long)}"
  end

  def overdue_summary(member)
    @member = member
    @loans = member.loans.overdue.includes(:tool).order(:due_on)
    mail to: member.email, subject: "#{@loans.size} #{"tool".pluralize(@loans.size)} overdue"
  end
end
