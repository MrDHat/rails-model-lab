module Api
  class PractitionersController < BaseController
    def index
      practitioners = Practitioner.active.includes(:location, :treatments).order(:name)
      practitioners = practitioners.joins(:treatments).where(treatments: { code: params[:treatment] }) if params[:treatment]
      render json: practitioners.map(&:as_api)
    end

    def show
      render json: Practitioner.active.find(params[:id]).as_api
    end
  end
end
