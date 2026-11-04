module Api
  class OrdersController < BaseController
    def create
      input = params.permit(:customer_email, :pickup_at, :notes, items: %i[sku quantity]).to_h
      items = Array(input[:items])
      errors = Hash.new { |hash, key| hash[key] = [] }
      customer = Customer.find_by(email: input[:customer_email]) if input[:customer_email].present?
      if input[:customer_email].blank? then errors[:customer_email] << "can't be blank"
      elsif !customer then errors[:customer_email] << "is not a customer"
      end
      errors[:items] << "can't be blank" if items.empty?
      skus = items.map { _1[:sku].to_s }
      (skus - Product.available.where(sku: skus).pluck(:sku)).uniq.each { errors[:items] << "has an unknown product: #{_1}" }
      unless items.all? { Integer(_1[:quantity].to_s, exception: false)&.between?(1, 20) }
        errors[:items] << "has a quantity outside 1 to 20"
      end
      pickup_at = input[:pickup_at].presence && (Time.zone.iso8601(input[:pickup_at]) rescue nil)
      errors[:pickup_at] << "is not a valid time" if input[:pickup_at].present? && !pickup_at
      return render json: { errors: errors }, status: :unprocessable_entity if errors.any?

      order = Order.place!(customer: customer, items: items.map { { sku: _1[:sku], quantity: _1[:quantity] } },
                           pickup_at: pickup_at, notes: input[:notes])
      render json: order.as_api, status: :created
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
