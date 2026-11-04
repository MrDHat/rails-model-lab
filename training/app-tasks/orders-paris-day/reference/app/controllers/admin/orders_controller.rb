module Admin
  class OrdersController < ApplicationController
    def index
      @day = params[:day].present? ? Date.parse(params[:day]) : Date.current
      @orders = Order.where(placed_at: @day.all_day).order(:placed_at)
    end

    def show
      @order = Order.find(params[:id])
    end
  end
end
