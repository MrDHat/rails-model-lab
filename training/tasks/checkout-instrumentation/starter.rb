module Checkout
  def self.call(order_id:, cents:)
    PaymentGateway.charge(cents)
  end
end
