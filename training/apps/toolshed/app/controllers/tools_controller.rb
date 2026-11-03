class ToolsController < ApplicationController
  before_action :set_tool, only: %i[show edit update]

  def index
    @tools = Tool.in_service.order(:name)
  end

  def show
    @loans = @tool.loans.order(created_at: :desc)
  end

  def new
    @tool = Tool.new
  end

  def create
    @tool = Tool.new(tool_params)
    if @tool.save
      redirect_to @tool, notice: "Tool added"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @tool.update(tool_params)
      redirect_to @tool, notice: "Tool updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_tool
    @tool = Tool.find(params[:id])
  end

  def tool_params
    params.require(:tool).permit(:name, :serial, :category_id, :daily_fee_cents)
  end
end
