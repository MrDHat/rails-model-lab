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
    return render(json: { imported: 0 }) if records.empty?

    now = Tool.connection.quote(Time.current)
    values = records.map do |r|
      "(#{r.values_at(:name, :serial, :category_id, :daily_fee_cents).map { Tool.connection.quote(_1) }.join(", ")}, #{now}, #{now})"
    end
    inserted = Tool.connection.exec_query(<<~SQL)
      INSERT INTO tools (name, serial, category_id, daily_fee_cents, created_at, updated_at)
      VALUES #{values.join(", ")} ON CONFLICT (serial) DO NOTHING RETURNING id
    SQL
    render json: { imported: inserted.length }
  end

  private

  def set_tool
    @tool = Tool.find(params[:id])
  end

  def tool_params
    params.require(:tool).permit(:name, :serial, :category_id, :daily_fee_cents)
  end
end
