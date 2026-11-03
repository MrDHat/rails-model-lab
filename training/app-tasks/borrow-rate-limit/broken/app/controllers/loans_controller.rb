class LoansController < ApplicationController
  before_action :require_member
  rate_limit to: 5, within: 1.minute, only: :create,
             with: -> { render plain: "Too many borrow attempts, try again in a minute", status: :too_many_requests }

  def create
    tool = Tool.find(params[:tool_id])
    loan = tool.loans.new(member: Current.member, due_on: params[:due_on].presence || 7.days.from_now.to_date)
    if loan.save
      redirect_to tool, notice: "Borrowed until #{loan.due_on.to_fs(:long)}"
    else
      redirect_to tool, alert: loan.errors.full_messages.to_sentence
    end
  end

  def return
    loan = Current.member.loans.open.find(params[:id])
    loan.return!
    redirect_to member_path(Current.member), notice: "Returned #{loan.tool.name}"
  end
end
