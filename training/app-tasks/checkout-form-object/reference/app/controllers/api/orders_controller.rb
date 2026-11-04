module Api
  class OrdersController < BaseController
    def create
      checkout = Checkout.new(params.permit(:customer_email, :pickup_at, :notes, items: %i[sku quantity]).to_h)
      if checkout.save
        render json: checkout.order.as_api, status: :created
      else
        render json: { errors: checkout.errors.to_hash }, status: :unprocessable_entity
      end
    end

    def show
      render json: Order.find(params[:id]).as_api
    end

    def update
      order = Order.find(params[:id])
      order.update!(status: Integer(params.require(:status)))
      PickupNotificationJob.perform_later(order) if order.ready?
      render json: order.as_api
    end
  end
end
