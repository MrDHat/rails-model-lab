# Texts the customer that their order can be picked up.
class PickupNotificationJob < ApplicationJob
  queue_as :default

  def perform(order, attempt = 1)
    return unless order.customer.phone

    SmsGateway.deliver(to: order.customer.phone, body: "Your Crumb order ##{order.id} is ready to collect.")
  rescue SmsGateway::Busy
    if attempt < 5
      self.class.set(wait: 30.seconds).perform_later(order, attempt + 1)
    else
      OrderMailer.ready(order).deliver_now
    end
  end
end
