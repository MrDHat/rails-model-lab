# Texts the customer that their order can be picked up.
class PickupNotificationJob < ApplicationJob
  queue_as :default

  def perform(order)
    return unless order.customer.phone

    SmsGateway.deliver(to: order.customer.phone, body: "Your Crumb order ##{order.id} is ready to collect.")
  end
end
