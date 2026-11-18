# Bills a completed appointment: one line for the treatment, the insurer's
# share from the patient's policy on the day, and a pending claim for that
# share.
class InvoiceBuilder
  def self.for(appointment) = new(appointment).build

  def initialize(appointment)
    @appointment = appointment
  end

  def build
    raise Invoice::NotPayable, "appointment ##{@appointment.id} isn't completed" unless @appointment.completed?
    raise Invoice::NotPayable, "appointment ##{@appointment.id} is already invoiced" if @appointment.invoice

    Invoice.transaction do
      invoice = Invoice.create!(patient: @appointment.patient, appointment: @appointment)
      treatment = @appointment.treatment
      invoice.invoice_lines.create!(description: "#{treatment.name} (#{I18n.l(@appointment.starts_at.to_date)})",
                                    quantity: 1, unit_price_cents: treatment.price_cents)
      invoice.recalculate!
      if (policy = @appointment.patient.current_policy(on: @appointment.starts_at.to_date))
        share = invoice.total_cents * policy.coverage_percent / 100
        invoice.update!(insurer_share_cents: share)
        invoice.create_insurance_claim!(insurer: policy.insurer, amount_cents: share) if share.positive?
      end
      invoice
    end
  end
end
