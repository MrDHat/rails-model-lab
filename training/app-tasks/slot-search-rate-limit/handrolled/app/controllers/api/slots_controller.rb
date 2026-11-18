module Api
  # GET /api/slots?practitioner_id=1&treatment=PHYS&date=2026-06-15
  class SlotsController < BaseController
    LIMIT = 30

    before_action :limit_searches

    def index
      practitioner = Practitioner.active.find(params.require(:practitioner_id))
      treatment = Treatment.active.find_by!(code: params.require(:treatment))
      date = Date.iso8601(params.require(:date))
      render json: { date: date.iso8601, slots: SlotFinder.new(practitioner, treatment).on(date).map(&:iso8601) }
    rescue Date::Error
      render json: { errors: ["Date must be YYYY-MM-DD"] }, status: :bad_request
    end

    private

    def limit_searches
      key = "slot-searches/#{current_client.id}/#{Time.current.to_i / 60}"
      count = Rails.cache.increment(key, 1, expires_in: 2.minutes)
      return if count <= LIMIT

      render json: { errors: ["Too many slot searches, try again in a minute"] }, status: :too_many_requests
    end
  end
end
