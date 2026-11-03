class OrderMailer < ApplicationMailer
  def receipt(order)
    @order = order
    mail to: order.customer.email, subject: "Your Crumb order ##{order.id}"
  end
end
