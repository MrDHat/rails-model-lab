Monitoring subscribes to "checkout.shop" with ActiveSupport::Notifications.
Checkout.call(order_id:, cents:) charges through PaymentGateway.charge and
returns its result. Each call must emit one "checkout.shop" event whose
payload includes order_id and cents and whose duration covers the charge. If
the charge raises, subscribers must still get the event with the exception
recorded, and the error must still reach the caller.
