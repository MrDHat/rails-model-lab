module Checkout
  def self.call(order_id:, cents:)
    payload = { order_id: order_id, cents: cents }
    started = Time.now
    PaymentGateway.charge(cents)
  rescue StandardError => e
    payload[:exception] = [e.class.name, e.message]
    payload[:exception_object] = e
    raise
  ensure
    ActiveSupport::Notifications.publish('checkout.shop', started, Time.now, SecureRandom.hex(10), payload)
  end
end
