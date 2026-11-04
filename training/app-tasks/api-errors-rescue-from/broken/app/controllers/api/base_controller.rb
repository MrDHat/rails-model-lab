module Api
  class BaseController < ActionController::API
    before_action :authenticate_client

    rescue_from(ActiveRecord::RecordNotFound) { render json: { error: "Not found" }, status: :not_found }

    private

    attr_reader :current_client

    def authenticate_client
      @current_client = ApiClient.find_by(token: params[:api_key].to_s)
      head :unauthorized unless current_client
    end
  end
end
