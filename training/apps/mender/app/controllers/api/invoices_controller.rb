module Api
  class InvoicesController < BaseController
    def index
      patient = Patient.find(params.require(:patient_id))
      invoices = patient.invoices.where.not(status: Invoice::DRAFT).order(issued_on: :desc).includes(:invoice_lines, :payments)
      render json: invoices.map(&:as_api)
    end

    # The app polls this while the patient is on the invoice screen.
    def show
      invoice = Invoice.where.not(status: Invoice::DRAFT).find_by!(number: params[:number])
      render json: invoice.as_api
    end
  end
end
