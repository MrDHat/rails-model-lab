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
      if params.key?(:notes)
        order.update!(notes: params[:notes])
      else
        order.update!(status: Integer(params.require(:status)))
        PickupNotificationJob.perform_later(order) if order.ready?
      end
      render json: order.as_api
    end
  end
end
