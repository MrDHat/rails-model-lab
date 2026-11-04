module Api
  class OrdersController < BaseController
    def create
      customer = Customer.find_by!(email: params.require(:customer_email))
      items = params.require(:items).map { { sku: _1[:sku], quantity: _1[:quantity] } }
      order = Order.place!(customer: customer, items: items, pickup_at: params[:pickup_at], notes: params[:notes])
      render json: order.as_api, status: :created
    end

    def show
      render json: Order.find(params[:id]).as_api
    end

    def update
      order = Order.find(params[:id])
      return update_items(order) if params.key?(:items)

      order.update!(status: Integer(params.require(:status)))
      PickupNotificationJob.perform_later(order) if order.ready?
      render json: order.as_api
    end

    private

    def update_items(order)
      unless order.status == Order::PLACED
        return render json: { errors: ["Order can't be changed once baking has started"] }, status: :unprocessable_entity
      end

      attributes = params.expect(items: [%i[id sku quantity remove]]).map do |item|
        if item[:id]
          { id: item[:id], quantity: item[:quantity], _destroy: item[:remove] }.compact
        else
          product = Product.available.find_by!(sku: item[:sku])
          { product_id: product.id, quantity: item[:quantity], unit_price_cents: product.price_cents }
        end
      end
      if order.update(order_items_attributes: attributes)
        render json: order.as_api
      else
        render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
