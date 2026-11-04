class OrderMailer < ApplicationMailer
  def receipt(order)
    @order = order
    @receipt_url = receipt_url(order.signed_id(purpose: :receipt, expires_in: 30.days))
    mail to: order.customer.email, subject: "Your Crumb order ##{order.id}"
  end
end
