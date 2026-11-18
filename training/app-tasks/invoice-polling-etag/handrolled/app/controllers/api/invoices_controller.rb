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
      body = invoice.as_api
      etag = %("#{Digest::SHA256.hexdigest(body.to_json)}")
      changed_at = [invoice.updated_at, *invoice.payments.map(&:updated_at), *invoice.invoice_lines.map(&:updated_at)].max
      response.headers["ETag"] = etag
      response.headers["Last-Modified"] = changed_at.httpdate
      return head :not_modified if request.headers["If-None-Match"] == etag

      render json: body
    end
  end
end
