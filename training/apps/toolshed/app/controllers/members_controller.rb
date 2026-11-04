class MembersController < ApplicationController
  def show
    @member = Member.find(params[:id])
    @loans = @member.loans.order(created_at: :desc)
  end
end
