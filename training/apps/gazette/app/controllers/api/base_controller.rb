module Api
  # The Gazette mobile app's API. Readers sign up through POST /api/reader and
  # then send their token as `Authorization: Bearer <token>`.
  class BaseController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate_reader

    rescue_from ActiveRecord::RecordNotFound do
      render json: { errors: ["Not found"] }, status: :not_found
    end
    rescue_from ActiveRecord::RecordInvalid do |error|
      render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
    end

    private

    attr_reader :current_reader

    def authenticate_reader
      @current_reader = authenticate_with_http_token { |token, _| Reader.find_by(api_token: token) }
      render json: { errors: ["Unauthorized"] }, status: :unauthorized unless current_reader
    end
  end
end
