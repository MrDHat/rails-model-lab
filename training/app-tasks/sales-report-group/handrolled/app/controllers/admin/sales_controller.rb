module Admin
  class SalesController < ApplicationController
    def show
      @from = Date.parse(params.require(:from))
      @to = Date.parse(params.require(:to))
      @rows = OrderItem.connection.select_rows(OrderItem.sanitize_sql([<<~SQL, @from.beginning_of_day, @to.end_of_day, Order::CANCELLED]))
        SELECT products.name, SUM(order_items.quantity), SUM(order_items.quantity * order_items.unit_price_cents) AS revenue
        FROM order_items
        JOIN orders ON orders.id = order_items.order_id
        JOIN products ON products.id = order_items.product_id
        WHERE orders.placed_at BETWEEN ? AND ? AND orders.status <> ?
        GROUP BY products.id, products.name
        ORDER BY revenue DESC
      SQL
    end
  end
end
