module Api
  class BaseController < ActionController::API
    before_action :authenticate_client
    around_action :render_errors_as_json

    private

    def render_errors_as_json
      yield
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Not found" }, status: :not_found
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    attr_reader :current_client

    def authenticate_client
      @current_client = ApiClient.find_by(token: params[:api_key].to_s)
      head :unauthorized unless current_client
    end
  end
end
