module Admin
  class OrdersController < ApplicationController
    def index
      @day = params[:day].present? ? Date.parse(params[:day]) : Date.current
      start = Time.new(@day.year, @day.month, @day.day, 0, 0, 0, "+01:00")
      @orders = Order.where(placed_at: start...(start + 1.day)).order(:placed_at)
    end

    def show
      @order = Order.find(params[:id])
    end
  end
end
