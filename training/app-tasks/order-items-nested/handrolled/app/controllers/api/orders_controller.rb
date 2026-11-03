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

      Order.transaction do
        params.expect(items: [%i[id sku quantity remove]]).each do |entry|
          if entry[:id]
            item = order.order_items.find(entry[:id])
            entry[:remove] ? item.destroy! : item.update!(quantity: entry[:quantity])
          else
            product = Product.available.find_by!(sku: entry[:sku])
            order.order_items.create!(product: product, quantity: entry[:quantity], unit_price_cents: product.price_cents)
          end
        end
        order.update!(total_cents: order.order_items.reload.sum { _1.quantity * _1.unit_price_cents })
      end
      render json: order.as_api
    rescue ActiveRecord::RecordInvalid => e
      order.reload
      render json: { errors: e.record.errors.full_messages.map { "Order items #{_1.downcase_first}" } }, status: :unprocessable_entity
    end
  end
end
