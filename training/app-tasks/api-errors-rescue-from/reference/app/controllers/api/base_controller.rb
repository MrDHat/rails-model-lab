module Api
  class BaseController < ActionController::API
    before_action :authenticate_client

    rescue_from(ActiveRecord::RecordNotFound) { render json: { error: "Not found" }, status: :not_found }
    rescue_from(ActionController::ParameterMissing) { render json: { error: _1.message }, status: :bad_request }
    rescue_from(ActiveRecord::RecordInvalid) { render json: { error: _1.message }, status: :unprocessable_entity }

    private

    attr_reader :current_client

    def authenticate_client
      @current_client = ApiClient.find_by(token: params[:api_key].to_s)
      head :unauthorized unless current_client
    end
  end
end
