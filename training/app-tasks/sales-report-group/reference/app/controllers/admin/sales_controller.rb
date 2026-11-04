module Admin
  class SalesController < ApplicationController
    def show
      @from = Date.parse(params.require(:from))
      @to = Date.parse(params.require(:to))
      items = OrderItem.joins(:order, :product)
                       .where(orders: { placed_at: @from.beginning_of_day..@to.end_of_day })
                       .where.not(orders: { status: Order::CANCELLED })
      revenue = items.group("products.id", "products.name").sum("order_items.quantity * order_items.unit_price_cents")
      units = items.group("products.id", "products.name").sum(:quantity)
      @rows = revenue.sort_by { -_2 }.map { |(id, name), cents| [name, units[[id, name]], cents] }
    end
  end
end
