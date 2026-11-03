module Admin
  class SalesController < ApplicationController
    def show
      @from = Date.parse(params.require(:from))
      @to = Date.parse(params.require(:to))
      items = OrderItem.includes(:order, :product)
                       .where(orders: { placed_at: @from.beginning_of_day..@to.end_of_day })
                       .where.not(orders: { status: Order::CANCELLED })
      @rows = items.group_by(&:product).map do |product, sold|
        [product.name, sold.sum(&:quantity), sold.sum { _1.quantity * _1.unit_price_cents }]
      end.sort_by { -_3 }
    end
  end
end
