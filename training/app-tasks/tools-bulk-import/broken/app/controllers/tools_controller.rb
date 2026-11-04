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

  def import
    rows = params.expect(tools: [%i[name serial category daily_fee_cents]])
    category_ids = Category.where(name: rows.map { _1[:category] }).pluck(:name, :id).to_h
    records = rows.filter_map do |row|
      next unless (category_id = category_ids[row[:category]])

      { name: row[:name], serial: row[:serial], category_id: category_id, daily_fee_cents: row[:daily_fee_cents].to_i }
    end
    imported = records.count { Tool.new(_1).save }
    render json: { imported: imported }
  end

  private

  def set_tool
    @tool = Tool.find(params[:id])
  end

  def tool_params
    params.require(:tool).permit(:name, :serial, :category_id, :daily_fee_cents)
  end
end
