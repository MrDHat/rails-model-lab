module Staff
  class InvoicesController < BaseController
    before_action :set_invoice, only: %i[show issue pay void]

    def index
      @status = params[:status].presence_in(Invoice::STATUS_NAMES.values) || "issued"
      @invoices = Invoice.where(status: Invoice::STATUS_NAMES.key(@status)).includes(:patient).order(created_at: :desc).limit(100)
    end

    def show
    end

    def create
      invoice = InvoiceBuilder.for(Appointment.find(params.require(:appointment_id)))
      redirect_to staff_invoice_path(invoice), notice: "Draft invoice #{invoice.number} created."
    end

    def issue
      @invoice.issue!
      InvoiceMailer.issued(@invoice).deliver_later
      ClaimSubmissionJob.perform_later(@invoice.insurance_claim) if @invoice.insurance_claim&.pending?
      redirect_to staff_invoice_path(@invoice), notice: "Issued."
    end

    def pay
      @invoice.record_payment!(amount_cents: Integer(params.require(:amount_cents)), method: params.require(:method),
                               reference: params[:reference])
      redirect_to staff_invoice_path(@invoice), notice: "Payment recorded."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to staff_invoice_path(@invoice), alert: e.record.errors.full_messages.to_sentence
    end

    def void
      @invoice.void!(reason: params.require(:reason))
      redirect_to staff_invoice_path(@invoice), notice: "Voided."
    end

    private

    def set_invoice
      @invoice = Invoice.find(params[:id])
    end
  end
end
