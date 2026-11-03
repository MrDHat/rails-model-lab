module Checkout
  def self.call(order_id:, cents:)
    ActiveSupport::Notifications.instrument('checkout.shop', order_id: order_id, cents: cents) do
      PaymentGateway.charge(cents)
    end
  end
end
