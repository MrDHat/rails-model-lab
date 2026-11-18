module Api
  # GET /api/slots?practitioner_id=1&treatment=PHYS&date=2026-06-15
  class SlotsController < BaseController
    rate_limit to: 30, within: 1.minute, with: -> {
      render json: { errors: ["Too many slot searches, try again in a minute"] }, status: :too_many_requests
    }

    def index
      practitioner = Practitioner.active.find(params.require(:practitioner_id))
      treatment = Treatment.active.find_by!(code: params.require(:treatment))
      date = Date.iso8601(params.require(:date))
      render json: { date: date.iso8601, slots: SlotFinder.new(practitioner, treatment).on(date).map(&:iso8601) }
    rescue Date::Error
      render json: { errors: ["Date must be YYYY-MM-DD"] }, status: :bad_request
    end
  end
end
