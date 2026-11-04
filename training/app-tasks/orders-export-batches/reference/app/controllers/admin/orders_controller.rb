module Admin
  class OrdersController < ApplicationController
    def index
      @day = params[:day].present? ? Date.parse(params[:day]) : Date.current
      @orders = Order.where(placed_at: @day.to_time(:utc)...(@day + 1).to_time(:utc)).order(:placed_at)
    end

    def export
      lines = []
      Order.includes(:customer, order_items: :product).find_each(batch_size: 500) { lines << _1.as_api.to_json }
      send_data lines.map { "#{_1}\n" }.join, type: "application/x-ndjson"
    end

    def show
      @order = Order.find(params[:id])
    end
  end
end
