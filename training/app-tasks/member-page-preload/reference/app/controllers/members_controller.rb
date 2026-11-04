class MembersController < ApplicationController
  def show
    @member = Member.find(params[:id])
    @loans = @member.loans.includes(tool: :category).order(created_at: :desc)
  end
end
