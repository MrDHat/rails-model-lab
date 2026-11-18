class InvoiceMailer < ApplicationMailer
  def issued(invoice)
    @invoice = invoice
    mail to: invoice.patient.email, subject: "Your Mender invoice #{invoice.number}"
  end
end
