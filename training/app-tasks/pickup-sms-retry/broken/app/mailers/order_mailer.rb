class OrderMailer < ApplicationMailer
  def receipt(order)
    @order = order
    mail to: order.customer.email, subject: "Your Crumb order ##{order.id}"
  end

  def ready(order)
    @order = order
    mail to: order.customer.email, subject: "Your Crumb order ##{order.id} is ready"
  end
end
