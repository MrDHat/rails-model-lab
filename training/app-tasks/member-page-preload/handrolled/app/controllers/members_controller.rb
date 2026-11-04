class MembersController < ApplicationController
  def show
    @member = Member.find(params[:id])
    @loans = @member.loans.order(created_at: :desc).to_a
    @tools = Tool.where(id: @loans.map(&:tool_id)).index_by(&:id)
    @categories = Category.where(id: @tools.values.map(&:category_id)).index_by(&:id)
  end
end
