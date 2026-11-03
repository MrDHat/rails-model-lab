# Texts the customer that their order can be picked up.
class PickupNotificationJob < ApplicationJob
  queue_as :default
  retry_on SmsGateway::Busy, wait: 30.seconds, attempts: 5 do |job, _error|
    OrderMailer.ready(job.arguments.first).deliver_now
  end

  def perform(order)
    return unless order.customer.phone

    SmsGateway.deliver(to: order.customer.phone, body: "Your Crumb order ##{order.id} is ready to collect.")
  end
end
