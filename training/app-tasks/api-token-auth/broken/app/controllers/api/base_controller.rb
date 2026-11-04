module Api
  class BaseController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate_client

    private

    attr_reader :current_client

    def authenticate_client
      @current_client = authenticate_with_http_token { |token, _options| ApiClient.find_by(token: token) } ||
                        ApiClient.find_by(token: params[:api_key].to_s)
      head :unauthorized unless current_client
    end
  end
end
