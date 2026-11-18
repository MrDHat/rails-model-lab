module Api
  class TreatmentsController < BaseController
    def index
      render json: Treatment.active.order(:name).map(&:as_api)
    end
  end
end
