module Checkout
  def self.call(order_id:, cents:)
    result = PaymentGateway.charge(cents)
    ActiveSupport::Notifications.instrument('checkout.shop', order_id: order_id, cents: cents)
    result
  end
end
