module Api
  # The patient app's API. Each app build sends its client token as
  # `Authorization: Bearer <token>`.
  class BaseController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate_client

    rescue_from ActiveRecord::RecordNotFound do
      render json: { errors: ["Not found"] }, status: :not_found
    end
    rescue_from ActiveRecord::RecordInvalid do |error|
      render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
    end
    rescue_from Appointment::InvalidTransition, Booking::Unavailable do |error|
      render json: { errors: [error.message] }, status: :unprocessable_entity
    end

    private

    attr_reader :current_client

    def authenticate_client
      @current_client = authenticate_with_http_token { |token, _| ApiClient.find_by(token: token) }
      render json: { errors: ["Unauthorized"] }, status: :unauthorized unless current_client
    end

    def parse_time(value)
      Time.zone.iso8601(value.to_s)
    rescue ArgumentError
      raise ActionController::BadRequest, "invalid time #{value.inspect}"
    end
  end
end
