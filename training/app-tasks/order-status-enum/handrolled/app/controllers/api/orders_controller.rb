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
      if order.update(status: Order.status_value(params.require(:status)) || -1)
        PickupNotificationJob.perform_later(order) if order.ready?
        render json: order.as_api
      else
        render json: { error: order.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    end
  end
end
