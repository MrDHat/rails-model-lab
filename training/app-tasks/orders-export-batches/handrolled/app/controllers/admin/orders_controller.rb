module Admin
  class OrdersController < ApplicationController
    def index
      @day = params[:day].present? ? Date.parse(params[:day]) : Date.current
      @orders = Order.where(placed_at: @day.to_time(:utc)...(@day + 1).to_time(:utc)).order(:placed_at)
    end

    def export
      lines = []
      last_id = 0
      loop do
        batch = Order.includes(:customer, order_items: :product).where("orders.id > ?", last_id).order(:id).limit(500).to_a
        break if batch.empty?

        batch.each { lines << _1.as_api.to_json }
        last_id = batch.last.id
      end
      send_data lines.map { "#{_1}\n" }.join, type: "application/x-ndjson"
    end

    def show
      @order = Order.find(params[:id])
    end
  end
end
