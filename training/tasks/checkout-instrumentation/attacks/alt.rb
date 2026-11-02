# Expected credit 0.0: emits the event after the charge, so the duration misses it.
module Checkout
  def self.call(order_id:, cents:)
    begin
      result = PaymentGateway.charge(cents)
    rescue => e
      ActiveSupport::Notifications.instrument('checkout.shop', order_id: order_id, cents: cents, exception: [e.class.name, e.message])
      raise
    end
    ActiveSupport::Notifications.instrument('checkout.shop', order_id: order_id, cents: cents)
    result
  end
end
